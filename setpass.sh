#!/bin/sh

mkdir -p /tmp/mkinitfs-dropbear/etc
cp /usr/share/mkinitfs/passwd /tmp/mkinitfs-dropbear/etc
echo -n "Password: "
read -r rawpass

pass=`echo $rawpass | mkpasswd`
echo root:$pass | chpasswd -e -R /tmp/mkinitfs-dropbear

mv /tmp/mkinitfs-dropbear/etc/passwd /etc/mkinitfs/dropbear
rm /tmp/mkinitfs-dropbear/etc/passwd-
rmdir /tmp/mkinitfs-dropbear/etc
rmdir /tmp/mkinitfs-dropbear
