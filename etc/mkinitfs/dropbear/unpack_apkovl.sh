#!/bin/sh
#
# apkovl unpack script which spawns dropbear and allows to enter decrypt key via ssh or console
#
# from ssh we allow 10 attempts until we stop ssh to avoid brute force attacks after which only 
# console can be used to enter decrypt key
#
# from console only 3 attempts are allowed before we drop into recovery shell
#
# note: this script is both ran by init and dropbear hence weird if-then-else structure in 
# unpack_apkovl_dropbear also since we are running two password promprs in parallel threads
# (console, ssh) each process needs to terminate other one for init to continue and exit value 
# must be determined by inspecting extracted files to know if wee succeeded or not
#

unpack_apkovl() {
        local ovl="$1"
        local dest="$2"
        local maxcount=$3
        local suffix=${ovl##*.}
        local i
        if [ "$suffix" = "gz" ]; then
                tar -C "$dest" -zxvf "$ovl" > $ovlfiles
                return $?
        fi

        # we need openssl. let apk handle deps
        apk add --initdb --repositories-file $repofile openssl || return 1

        if ! openssl list -1 -cipher-commands | grep "^$suffix$" > /dev/null; then
                errstr="Cipher $suffix is not supported"
                return 1
        fi
        local count=0
        # beep
        echo -e "\007"
        while [ $count -lt $maxcount ]; do
                openssl enc -d -$suffix -in "$ovl" | tar --numeric-owner \
                        -C "$dest" -zxv >$ovlfiles 2>/dev/null
                # exit if any files were extracted (either by console or ssh prompt)
                # note that if apkovl is empty then we are stuck
		[ -s $ovlfiles ] && return 0 
                count=$(( $count + 1 ))
        done
        return 1
}

unpack_apkovl_dropbear() {
        if [ ! -f /run/dropbear.pid ]; then
                # we are ran by init - configure authentication and spawn dropbear 
                if [ -s /etc/mkinitfs/dropbear/authorized_keys ]; then
                        mkdir -p /root/.ssh
                        chmod 0700 /root/.ssh
                        cp /etc/mkinitfs/dropbear/authorized_keys /root/.ssh
                        chmod 0600 /root/.ssh/authorized_keys
                fi
                if [ -s /etc/mkinitfs/dropbear/passwd ]; then
                         cp /etc/mkinitfs/dropbear/passwd /etc
                fi
                ovl="$ovl" sysroot="$sysroot" repofile="$repofile" /usr/sbin/dropbear \
                         -r /etc/mkinitfs/dropbear/dropbear_rsa_host_key \
                         -e -E -m -j -k \
                         -P /run/dropbear.pid \
                         -p 22 \
                         -c "/etc/mkinitfs/dropbear/unpack_apkovl.sh"
                # also prompt for password from console
                unpack_apkovl "$ovl" "$sysroot" 3
                # console prompt finished, terminate dropbear and init can continue
                killall -q dropbear
        else
		# we are ran by dropbear - prompt password via ssh
                unpack_apkovl "$ovl" "$sysroot" 10
                # ssh prompt finished, terminate console prompt IF decrypt succeeded - otherwise let it run as a backup
		[ -s $ovlfiles ] && killall -q openssl 
		# always terminate dropbear
		killall -q dropbear
        fi
}

ovlfiles=/tmp/ovlfiles
unpack_apkovl_dropbear 
[ -s $ovlfiles ] || (ovlfiles= && false)
