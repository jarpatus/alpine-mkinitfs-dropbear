#!/bin/sh

apk add patch
patch -d /usr/share/mkinitfs < initramfs-init.patch

mount -o remount,rw /boot
mkinitfs -o /boot/initramfs-dropbear
mount -o remount,ro /boot
