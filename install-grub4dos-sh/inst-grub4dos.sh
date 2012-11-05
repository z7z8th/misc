#!/bin/sh

die()
{
		echo "\033[31m*** $1"
		echo "exiting ....\033[0m"
		exit 1
}

check_bin_existence()
{
    which "$1" 2>&1 1>/dev/null || die "$1 was not in PATH"
}

check_bin_existence udevadm
check_bin_existence gawk
check_bin_existence dd

test "$#" = "1" || die "usage: $0 path/to/udisk"

#check if the parameter is whole disk
test -e "/dev/$1" || die "$1 does not exists" 
test -z "$(echo $1 | grep '[[:digit:]]')" || die 'i can only proceed on hole disk, e.g. sda hda sdb... *not* sda1 sdb2'

#check usb disk info
udev_info=`udevadm --debug info --query=all --name=$1 2>/dev/null`
isusb=`echo $udev_info | grep 'ID_BUS=usb'`
test -n "$isusb" && echo "$1 is usb device, will install grldr.mbr" \
		|| die "$1 is not usb device, maybe dangerous!"

#check sector size
chk_sector_size=`fdisk -u -l /dev/$1 | grep -i 'Sector size.*512.*512'`
echo chk_sector_size=$chk_sector_size

#check if usb disk have enough sectors for grldr.mbr
test -n "$chk_sector_size" || die "sector size is not 512 bytes, i don't know the result, so exit"
start_sector="`fdisk -u -l /dev/$1 | grep -E $1[0-9]+ | head -n 1 | gawk '{print $2}'`"
echo start_sector=$start_sector
test "$start_sector" -gt 18 \
    || die "not enough sectors before the first partition of $1, can't write grldr.mbr"

[ ! -e "./grldr.mbr" ] && die "grldr.mbr does not exists in current dir"

read -p "please make sure you really want to proceed writting on $1.
press enter to write OR Ctrl+C to exit
"

dd if=/dev/$1 of=/dev/$1 bs=512 seek=1 count=1 >/dev/null \
		|| die "fail to backup the 1st sector of $1 to its 2nd sector"
dd if=grldr.mbr of=/dev/$1 bs=440 count=1 >/dev/null \
		|| die "fail to copy first 440 byptes of grldr.mbr to $1"
dd if=grldr.mbr of=/dev/$1 bs=1k skip=1 seek=1 count=8 >/dev/null \
		|| die "fail to copy left part(last 8kB) of grldr.mbr to $1"

echo "=======================
Congratulations!!!!
install grldr.mbr to $1 completed successful, please copy grldr to one partition of $1"

