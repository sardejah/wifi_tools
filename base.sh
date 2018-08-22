#!/bin/bash
echo "usage: base.sh net_iface_name ap_iface_name"
#variables
NET_IFACE=$1
ROGUE_IFACE=$2
ESSID="yami"
#BSSID=00:24:D3:44:11:C0
CHANNEL=6
PASSWORD="ulysse31"

#kill
service dnsmasq stop
pkill hostapd

#configurations files
rm /etc/hostapd/hostapd.conf
echo "interface=$ROGUE_IFACE
hw_mode=g
channel=$CHANNEL
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
ssid=$ESSID
wpa_passphrase=$PASSWORD" > /etc/hostapd/hostapd.conf

rm /etc/dnsmasq.conf
echo "dhcp-range=$ROGUE_IFACE,192.168.1.10,192.168.1.20,255.255.255.0,24h
server=8.8.8.8
server=8.8.4.4" > /etc/dnsmasq.conf

#configurations routing
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t nat -A POSTROUTING -o $NET_IFACE -j MASQUERADE
iptables -A FORWARD -i $NET_IFACE -j ACCEPT

#RUN
ifconfig $ROGUE_IFACE down
#macchanger -m $BSSID $ROGUE_IFACE
macchanger -r $ROGUE_IFACE
ifconfig $ROGUE_IFACE up
hostapd /etc/hostapd/hostapd.conf &
service dnsmasq restart
ifconfig $ROGUE_IFACE up 
ifconfig $ROGUE_IFACE 192.168.1.1 netmask 255.255.255.0
