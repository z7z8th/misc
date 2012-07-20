iwconfig wlan0 essid hello mode ad-hoc key 1236547890
ifconfig wlan0 10.0.0.2/24
route del default 
route add default gw 10.0.0.1 dev wlan0
