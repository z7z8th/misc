#!/bin/sh

[ ! -e "$HOME/.vnc/passwd" ] && vnc4passwd

echo "========================="
cat ~/.vnc/xstartup
echo "========================="


killall -TERM Xvnc4
sleep 1
killall -9 Xvnc4

ps aux|grep -i vnc

read -p "previous vnc server killed, start new server?" pp

vnc4server -geometry 1280x1024
