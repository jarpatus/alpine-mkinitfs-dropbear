# Alpine Linux (rootless) mkinitfs Dropbear support
Quick patch to add Dropbear support to Alpine Linux' mkinitfs. Allows to enter password to apkovl decrypt prompt via SSH session (not for cryptsetup atm sorry).

These instructions are quite vague at the moment so please know what you are doing.

# Requirements
Packages ```dropbear``` and ```patch``` must be installed. Don't enable dropbear service (unless you need it of course).

# Installation
* Put files from /etc to /etc. Adjust /etc/mkinitfs/mkinitfs.conf if needed.
* Apply patch to initramfs-init: ```patch -d /usr/share/mkinitfs < initramfs-init.patch```

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
* Create a new initramfs: mkinitfs -t /opt/mkinitfs/tmp -k -o /boot/initramfs-dropbear
* Reboot
