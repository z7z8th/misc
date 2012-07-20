#!/bin/sh

[ "$1" = "" -o "$1" != "i" -a "$1" != "d" ] && {
	echo "specify a parameter: i or d (i:intel, d:ati)";
	exit 1;
}

xorg_conf=/etc/X11/xorg.conf 

[ "$1" = "i" ] && { 
	echo "change to intergrated intel graphics card";
	[ -e $xorg_conf ] && mv -f $xorg_conf /root/;
	aticonfig --px-igpu;
}

[ "$1" = "d" ] && { 
	echo "change to decrete ati graphics card";
	aticonfig --px-dgpu;
}

aticonfig --pxl
