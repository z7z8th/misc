#!/bin/sh

export LANG=POSIX

get_rx_val()
{
    rx_val=$(ifconfig eth0 |grep -o 'RX bytes:[0-9]*')
    rx_val=${rx_val#*:}
    echo $rx_val
}

rx_last=$(get_rx_val)
/bin/echo -en "\033[s"
while true;
do
    sleep 1
    rx_current=$(get_rx_val)
    /bin/echo -en "\033[u\033[K$(date +%c) >> Down Speed >>  $(((rx_current-rx_last)/1024)) KB/s"
    rx_last=$rx_current
done
