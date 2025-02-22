# Alpine Linux (rootless) mkinitfs Dropbear support
Quick patch to add Dropbear support to Alpine Linux' mkinitfs. Allows to enter password to apkovl decrypt prompt via SSH session (not for cryptsetup atm sorry).

# Requirements
Packages ```dropbear``` and ```patch``` must be installed. Don't enable dropbear service (unless you need it of course).

# Installation
* Put files from /etc to /etc. Adjust /etc/mkinitfs/mkinitfs.conf if needed.
* Generate Dropbear host keys: ```dropbearkey  -t rsa -s 4096 -f dropbear_rsa_host_key```
* Apply patch to initramfs-init: ```patch -d /usr/share/mkinitfs < initramfs-init.patch```

## Password authentication
For password authentication /etc/mkinitfs/passwd should contain your password.
```
echo mypasswd > /etc/mkinitfs/passwd
chmod 0600 /etc/mkinitfs/passwd
```

## Certificate authentication
