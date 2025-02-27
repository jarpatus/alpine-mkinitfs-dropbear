# Alpine Linux (diskless) mkinitfs Dropbear support
Quick patch to add Dropbear support to Alpine Linux' mkinitfs. Allows to enter password to apkovl decrypt prompt via SSH session (not for cryptsetup atm sorry).

Please know what you are doing if you use these instructions and files.

# Use cases
You can run diskless Alpine Linux installation with what is almost like full disk encryption as your apkovl files are encrypted. You can then also full disk encrypt all remaining drives using technology of your choice and decrypt them from /etc/fstab, /etc/local.d or so.

# Requirements
Package ```dropbear``` must be installed. Don't enable dropbear service (unless you need it of course). Perhaps it would be good idea to install dropbear only temprarily in build script if not used...

# Installation
* Copy ./etc to /etc
* Adjust /etc/mkinitfs/mkinitfs.conf if needed

## Host keys
* Generate Dropbear host keys: ```dropbearkey  -t rsa -s 4096 -f dropbear_rsa_host_key```

## Password authentication
* For password authentication use ```setpass.sh``` to generate ```/etc/mkinitfs/dropbear/passwd``` which is then used for password authentcation

## Certificate authentication
For certificate based authentication generate client SSH key using technology of your choice and put it to /etc/mkinitfs/authorized_keys:

```
nano /etc/mkinitfs/authorized_keys
chmod 0600 /etc/mkinitfs/authorized_keys
```

## Bootloader
* Create a new menu entry for dropbear to your bootloader (keep original one intact just in case something goes wrong)
* Add ```dropbear``` kernel option to your new menu entry (do not add ```ip=dhcp``` as it seems to do something weird)
* Use ```initramfs-dropbear``` instead of ```initramfs-lts``` as initrd 

## lbu
Modify ```/etc/lbu/lbu.conf``` and add uncomment ```ENCRYPTION=$DEFAULT_CIPHER``` and optionally add ```PASSWORD=xxx```

## Create initramfs
* Use ```build.sh``` to build a new initramfs (customize if needed, script does some assumptions like that /boot is mounted)
* Don't forget to ```lbu commit```
* Reboot

# Problems
* If ip=xxx kernel option is added then init script won't work with local package cache anymore and everything goes south. As a workround we bring up network by ourselved but then only DHCP does work... Have had no time to figure out how to make this work.
* Randomly after decryption boot halts when openrc tries to load modules for hardware. This happens only with this patch so it must be related to network modules already being loaded or so.
