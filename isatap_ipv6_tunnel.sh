#!/bin/sh

echo "IFACE=$IFACE"
echo "LOGICAL=$LOGICAL"
echo "ADDRFAM=$ADDRFAM"
echo "METHOD=$METHOD"


[ x$METHOD != xppp -o x$ADDRFAM != xinet ] && { echo "METHOD=$METHOD, ADDRFAM=$ADDRFAM, not capable to setup isatap! exit!"; exit 1; }

tunnel_if=ppp0


do_start() {
    isatap_svr_dn=isatap.sjtu.edu.cn
    isatap_svr_inet_addr=`nslookup $isatap_svr_dn | grep '^Address: ' | cut -d ' ' -f 2`
    echo "isatap_svr_inet_addr=$isatap_svr_inet_addr"

    echo "wait for if $tunnel_if to come up"
    until ip link show $tunnel_if 2>&1 1>/dev/null; do 
        echo -n '.';
        sleep 1;
    done
    if_inet_addr=`ip -4 -o addr show dev ppp0 | awk '{print $4}'`
    echo "if_inet_addr=$if_inet_addr"
    echo $if_inet_addr | grep '[0-9.]*' || { echo "fail to get inet addr on if $tunnel_if! exit!"; exit 1; }

    ip tunnel del isatap_tunnel

    set -xe
    ip tunnel add isatap_tunnel mode isatap remote $isatap_svr_inet_addr local $if_inet_addr
    ip link set isatap_tunnel up
    ip tunnel prl prl-default $isatap_svr_inet_addr dev isatap_tunnel
    ip -6 route add default via fe80::5efe:$isatap_svr_inet_addr dev isatap_tunnel
    set +xe
}


do_stop() {
    ip tunnel del isatap_tunnel
}


echo "$0 $IFACE $MODE $PHASE"

case $MODE in
    start)
        case $PHASE in
            post-up)
                do_start
                ;;
        esac
        ;;
    stop)
        case $PHASE in
            pre-down)
                do_stop
                ;;
        esac
        ;;
    *)
        echo "unknow mode: $MODE"; 
        exit 1;
        ;;
esac

rdisc6 isatap_tunnel

exit 0
