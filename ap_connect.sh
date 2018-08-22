#!/bin/bash

red_echo() {
    echo -e "\x1b[1;31m$MESSAGE\e[0m"
}

green_echo() {
    echo -e "\x1b[1;32m$MESSAGE\e[0m"
}

enc_type=$1
if=$2
ap=$3
pass=$4
echo "usage: ap_connect.sh <enc_type:WPA,WEP,OPN> <IF_NAME> <AP_NAME> <PASSWORD>"

if [ -e ap_connect.conf ];
then 
	MESSAGE="A conf file exist:" ; red_echo
	MESSAGE="___________________" ; red_echo
	MESSAGE=$(cat ap_connect.conf) ; red_echo
	MESSAGE="___________________" ; red_echo
	read -p "Do you want to use these settings? (y/N): " yn
	if [[ "$yn" == y ]];
	then
		echo "Loading conf's ..." 
		source ./ap_connect.conf
		enc_type=$ap_type
		ap=$essid
		pass=$password
		read -p "Do you want to use the same interface? (Y/n) : " yn2
		if [[ "$yn2" == n ]];
		then
			read -p "Type interface name to use : " interface_name
		fi
		if=$interface_name

	fi

else echo "No config file, continuing..."
fi

MESSAGE="___________________" ; red_echo
if [[ "$yn2" == n ]];
then
	MESSAGE="interface_name=$if" ; green_echo
else
	MESSAGE="interface_name=$if" ; red_echo
fi
MESSAGE="ap_type=$enc_type" ; red_echo
MESSAGE="essid=$ap" ; red_echo
MESSAGE="password=$pass" ; red_echo
MESSAGE="___________________" ; red_echo

if [[ "$yn2" == n ]];
then
	read -p "Do y want to save these settings for future use ? (y/n): " yn3
	if [[ "$yn3" == y ]];
	then 
		rm ap_connect.conf
		echo "interface_name=$if
ap_type=$enc_type
essid=$ap
password=$pass" > ap_connect.conf
		
	fi
fi

rm wpa_connect.conf
echo "country=FR
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

" > wpa_connect.conf
chmod 777 wpa_connect.conf

dhclient $if -r

if [[ "$if" == wlan0 ]] && [ ! -e /var/run/wpa_supplicant/wlan0.pid ];
then
	pkill wpa_supplicant
else
	pid=$(cat /var/run/wpa_supplicant/$if.pid)
	kill $pid
	#rm /var/run/wpa_supplicant/$if
	rm /var/run/wpa_supplicant/$if.pid
fi


ifconfig $if down
macchanger -r $if
ifconfig $if up

if [[ "$enc_type" == *WPA* ]]; then 
	wpa_passphrase $ap $pass >> wpa_connect.conf
	wpa_supplicant -P /var/run/wpa_supplicant/$if.pid -o nl80211 -B   -i $if   -c wpa_connect.conf | grep Successfully
elif [[ "$enc_type" == *WEP* ]]; then 
	iwconfig $if essid $ap key s:$pass
elif [[ "$enc_type" == *OPN* ]]; then 
	rm wpa_connect.conf
	echo "
network={
ssid=\"$ap\"
key_mgmt=NONE
}" >> wpa_connect.conf
	chmod 777 wpa_connect.conf
	wpa_supplicant  -P /var/run/wpa_supplicant/$if.pid  -B -o nl80211 -i $if   -c wpa_connect.conf | grep Succesfully
else
    echo "AP type error" && exit
fi

rm dhclient.lease
kill $(cat dhclient.$if.pid)
touch dhclient.lease
gateway=$( route -n | grep US | grep $if | awk '{ print $2 }')
echo $gateway
#route del default gw $gateway $if
dhclient $if -v -lf dhclient.lease -pf dhclient.$if.pid
gateway=$(cat dhclient.lease | grep routers | awk '{ print $3 }' | sed s'/.$//')
route add default gw $gateway $if

iwconfig $if | grep Point | awk '{ print $4, $5, $6 }'
ifconfig $if | grep inet
iw $if link | grep SSID
route -n | grep $if
exit
