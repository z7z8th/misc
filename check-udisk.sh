#!/bin/sh

echo "usage: $0 path/to/disk  udisk_size_in_GB_unit"
[ -n "$1" -a -e "$1" ] && udisk=$1 || { echo "please specific a valid disk!";  exit 1; }
[ 0 -lt "$2" -a "$2" -lt 15 ] && udisk_size_GB=$2 || { echo "please specific a valid test size in GB unit, i.e. 4";  exit 1; } 

local_disk_file=sdb11.raw
local_disk_md5_file=$sdb11_file.md5
bs="1M"
count=1024

echo "$local_disk_file md5=$sdb11_file_md5"
echo "bs=$bs"
echo "count=$count"

[ ! -e "$local_disk_file" ] && { 
    echo "dd to $local_disk_file";
    local_disk_file_md5=$(dd if=/dev/sdb11 bs=$bs count=$count | tee $sdb11_file | md5sum | cut -f 1 -d " ");
} || {
    [ ! -e "$local_disk_md5_file" ] && { 
        echo "checking md5 of $local_disk_file";
        local_disk_file_md5=$(md5sum $sdb11_file | cut -f 1 -d " "); 
    };
}

[ ! -e "$local_disk_md5_file" ] && {
    echo "saving md5 of $local_disk_file to $sdb11_md5_file"
    echo "$local_disk_file_md5" > $sdb11_md5_file;
} || { 
    local_disk_file_md5=$(cat $sdb11_md5_file);  
}

i=0
echo "checking udisk..."
while [ "$i" -lt "$udisk_size_GB" ]; 
do
    echo "\n\nindex >> $i"
    offset=$((i*count))
    echo "offset=$offset"
    echo "dd $local_disk_file to $udisk"
    dd if=$local_disk_file of=$udisk seek=$offset bs=$bs count=$count
    echo "check md5 of $udisk "
    disk_part_md5=$(dd if=$udisk skip=$offset bs=$bs count=$count | md5sum | cut -f 1 -d " ")
    [ "$local_disk_file_md5" = "$disk_part_md5" ] && { echo "md5sum ok"; } || { echo "md5sum error"; exit 1; }
    i=$((i+1))

done
