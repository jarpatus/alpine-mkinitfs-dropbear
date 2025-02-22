# Alpine Linux (rootless) mkinitfs Dropbear support
Quick patch to add Dropbear support to Alpine Linux' mkinitfs. Allows to enter password to apkovl decrypt prompt via SSH session (not for cryptsetup atm sorry).

These instructions are quite vague at the moment so please know what you are doing.

# Use cases
You can run diskless server with what almost like full disk encryption as your apkovl files are encrypted and only initramfs is not crypted. You can then also full disk encrypt all remaining drives and decrypt them from fstab, local.d or so and place encryption key to somewhere in /etc so it will be included in encrypted aplocl.

# Requirements
Packages ```dropbear``` and ```patch``` must be installed. Don't enable dropbear service (unless you need it of course).

# Installation
* Put files from /etc to /etc. Adjust /etc/mkinitfs/mkinitfs.conf if needed.
* Apply patch to initramfs-init: ```patch -d /usr/share/mkinitfs < initramfs-init.patch```

Note that if we are diskless then patched initramfs-init won't survive the boot!

## Host keys
* Generate Dropbear host keys: ```dropbearkey  -t rsa -s 4096 -f dropbear_rsa_host_key```

## Password authentication
For password authentication /etc/mkinitfs/passwd should contain your password. This may not be great idea since if somebody pulls your disks out then password can be just read out. Use certificate authentication instead or at very least use password which is not used anywhere else.
```
echo mypasswd > /etc/mkinitfs/passwd
chmod 0600 /etc/mkinitfs/passwd
```

## Certificate authentication
For certificate based authentication generate client SSH key and put it to /etc/mkinitfs/authorized_keys:

```
nano /etc/mkinitfs/authorized_keys
chmod 0600 /etc/mkinitfs/authorized_keys
```

## Bootloader
* Create a new menu entry for dropbear or so to your bootleader (keep original one intact just in case something goes wrong).  
* Add ```dropbear``` kernel option to your new entry (do not add ```ip=dhcp``` as it seems to do something weird?)
* Change initrd to initramfs-dropbea instead of initramfs-lts

## Create initramfs
* Create a new initramfs: ```mkinitfs -t /opt/mkinitfs/tmp -k -o /boot/initramfs-dropbear```
* Reboot

## lbu
Modify ```/etc/lbu/lbu.conf``` and add uncomment ```ENCRYPTION=$DEFAULT_CIPHER``` and optionally add ```PASSWORD=xxx```.

# Problems
* If ip=xxx kerlen option is added then init script won't work with local package cache anymore and everything goes south. As a workround we bring up network by ourselved but then only DHCP does work... Have had no time to figure out this yet.
* Randomly after decryption boot halts when openrc tries to load modules for hardware. This happens only with this patch so it must be related to network modules already being loaded or so.
