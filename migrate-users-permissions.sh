#!/bin/sh

#dd if=/dev/urandom bs=512 count=1 2>/dev/null | md5sum -b | cut -d' ' -f1

users_disabled='xyz:x:500:100::/home/xyz:/bin/bash
abc:x:501:100::/home/abc:/bin/bash
'
users_disabled=`echo "$users_disabled" | cut -d: -f1,3`

users_migrate='def:503:def.aa
ghi:504:ghi.bb'

echo "users_disabled=\n$users_disabled\n"
echo "users_migrate=\n$users_migrate\n"

smb_path_prefix=/srv/smb/data

chown_for_user () {
    [ -z "$1" -o -z "$2" ] && { echo "*** chown_for_user: old uid and new username can not be null"; return; }
    find ${smb_path_prefix}a ${smb_path_prefix}b -uid $1 -exec chown $2:users {} +
}

usermapfile="usermap.file"
usermapall=''
echo -n $usermapall > $usermapfile

newuid=1002
for user_info in `echo "$users_disabled\n$users_migrate"`; do
    oldname=`echo $user_info | cut -d: -f1`
    olduid=`echo $user_info | cut -d: -f2`
    newname=`echo $user_info | cut -d: -f3`
    [ -z "$newname" ] && newname=$oldname
    echo "oldname=$oldname"
    echo "olduid=$olduid"
    echo "newname=$newname"
    echo "newuid=$newuid"
    usermap="$oldname:$olduid:$newname:$newuid"
    usermapall="$usermapall\n$usermap"
    #echo "$usermap" >>$usermapfile
    #useradd --uid $newuid --gid users -m $newname
    #[ -n "$olduid" ] && chown_for_user $olduid $newname

    newuid=$((newuid+1))
    echo
done

echo "$usermapall"

for userinfo in `echo "$users_migrate"`; do
    username=`echo $userinfo | cut -d: -f3`
    echo "change password for: $username"
    #echo "$username:${username}" | chpasswd
    #echo "${username}\n${username}\n" | smbpasswd -as $username

    echo "make default directory for: $username"
    #mkdir -p ${smb_path_prefix}a/$newname ${smb_path_prefix}b/$newname

    echo "change home dir and shell"
    #rm -rf /home/$username
    #usermod -d ${smb_path_prefix}a/$username -s /bin/bash $username
    #cp -afv /etc/skel/. ${smb_path_prefix}a/$username
    #chown -R $username:users ${smb_path_prefix}a/$username   ${smb_path_prefix}b/$username
    echo 
done


for userinfo in `echo "$users_disabled"`; do
    username=`echo $userinfo | cut -d: -f1`
    echo "disable user login: $username"
    #usermod -s /usr/sbin/nologin $username
done
