#!/bin/zsh
export PATH=/usr/local/bin:$PATH

CARDID='xxxxxx'
PASSWORD='xxxxxx'

# not use wireless network card adapter to capture the wifi name.

# Wired network card
ETH_ADPs='en5'
# sepreate with colon :
#ETH_ADPs='enp4s0:eth0'

# get the names of all the adapters by:
#networksetup -listallhardwareports
# device name is like en0 en1 .etc
# if the Hardware Port is not or are not only "Thunderbolt Ethernet", modify the following lines
#ETH_ADPs="$ETH_ADPs:$(networksetup -listallhardwareports |grep "Thunderbolt Ethernet" -A 1 |awk '{if (NR==2){print $2}}')"
#ETH_ADPs="$(echo "$ETH_ADPs"|sed 's/^:*//;s/:*$//')" # removing prefix suffix colon

# connect to "drcom.szu.edu.cn"
APs_192="SZU_WLAN"
# sepreate with colon :
#APs_192="SZU_WLAN:xxxxxx"

# connect to "172.30.255.2/a30.htm"
APs_172="SZU_NewFi"
# sepreate with colon :
#APs_172="SZU_NewFi:xxxxx"

# modify the following line with the mac address of the Ethernet router which needs to log in with "drcom.szu.edu.cn"
# you can get the mac_address with "get_router_mac" function by uncomment get_router_mac at last
ETH_GATEWAY_MACs_192="xx:xx:xx:xx:xx:xx"
# sepreate with SPACE
#ETH_GATEWAY_MACs_192="xx:xx:xx:xx:xx:xx xx:xx:xx:xx:xx:xx"

# SZU_Eth mask
# modify the following line with the mac address of the Ethernet router which needs to log in with "172.30.255.2/a30.htm"
ETH_GATEWAY_MACs_172="xx:xx:xx:xx:xx:xx"
# sepreate with SPACE
#ETH_GATEWAY_MACs_172="xx:xx:xx:xx:xx:xx xx:xx:xx:xx:xx:xx"



get_router_mac(){
    # sep with space
    ETH_GATEWAY_MACs_NOW=""
    while read ETH_ADP; do
	ETH_GATEWAY_IPs_NOW="$(ip -4 route list |grep "$ETH_ADP" | grep default |cut -d ' ' -f 3)"
	[ -n "$ETH_GATEWAY_IPs_NOW" ] && ETH_GATEWAY_MACs_NOW="$ETH_GATEWAY_MACs_NOW $(ip neigh | grep "$ETH_GATEWAY_IPs_NOW" |awk '{print $5}')"
    done < <(echo "$ETH_ADPs" | tr ':' '\n')
    ETH_GATEWAY_MACs_NOW="$(echo $ETH_GATEWAY_MACs_NOW|xargs)" # removing the prefix and suffix space
    echo "$ETH_GATEWAY_MACs_NOW"
}

drcom_login(){
    # Usage: drcom_login 0MKKey login_url
    pinginfo="$(ping -c 1 -W 10 baidu.com |grep " 0% packet loss")"

    # pinginfo='' # for test
    #empty when not connected
    if [ -z "$pinginfo" ]; then
	/usr/bin/curl -d "DDDDD=$CARDID" -d "upass=$PASSWORD" -d "0MKKey=$1" "$2" > /dev/null 2>& 1
    fi
}

main(){
    while true
    do

	# ========================== wireless BEGIN ==============================
	AP_NOW=""
	AP_NOW="$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I |sed -n 's/ \{11\}SSID: \(.*\)/\1/p')"
	#echo "$AP_NOW"
	
	# use regex rather then use for loop link in windows
	# login
	[ -n "AP_NOW" ] && if [[ ":$APs_192:" =~ :"$AP_NOW": ]]; then # AP_NOW in $AP_192 ; ref: /etc/profile append_path()
	    # same as  [[ ":$APs_192:" =~ .*:"$AP_NOW":.* ]]
	    echo 1
	    drcom_login "123456" "https://drcom.szu.edu.cn/a70.htm"
	    sleep 5
	    continue
	elif [[ ":$APs_172:" =~ :"$AP_NOW": ]]; then
	    echo 2
	    drcom_login "%B5%C7%A1%A1%C2%BC" "http://172.30.255.2/a30.htm"
	    sleep 5
	    continue
	fi
	# ========================== wireless END ================================


	#ETH_GATEWAY_IPs_NOW=""
	#ETH_GATEWAY_MACs_NOW=""
	## sep with return \n
	#ETH_GATEWAY_IPs_NOW=$(ip -4 route list | grep default |cut -d ' ' -f 3) # find all the gateways, including the wireless
	#ETH_GATEWAY_MACs_NOW=$(ip neigh | grep "$ETH_GATEWAY_IPs_NOW" |awk '{print $5}')
	##echo $ETH_GATEWAY_MACs_NOW
	
	# ========================== ethernet START ================================
	# sep with space
	ETH_GATEWAY_MACs_NOW=""
	while read ETH_ADP; do
	    ETH_GATEWAY_IPs_NOW="$(ip -4 route list |grep "$ETH_ADP" | grep default |cut -d ' ' -f 3)"
	    ETH_GATEWAY_MACs_NOW="$ETH_GATEWAY_MACs_NOW $(ip neigh | grep "$ETH_GATEWAY_IPs_NOW" |awk '{print $5}')"
	done < <(echo "$ETH_ADPs" | tr ':' '\n')
	ETH_GATEWAY_MACs_NOW="$(echo $ETH_GATEWAY_MACs_NOW|xargs)" # removing the prefix and suffix space
	#echo "$ETH_GATEWAY_MACs_NOW"

	while read ETH_GATEWAY_MAC_NOW; do
	    #echo line="$ETH_GATEWAY_MAC_NOW";
	    if [[ "$ETH_GATEWAY_MACs_192" =~ "$ETH_GATEWAY_MAC_NOW" ]]; then # AP_NOW in $AP_192 ; ref: /etc/profile append_path()
		drcom_login "123456" "https://drcom.szu.edu.cn/a70.htm"
		#echo 192
		sleep 5
		continue 2
	    elif [[ "$ETH_GATEWAY_MACs_172" =~ "$ETH_GATEWAY_MAC_NOW" ]]; then
		drcom_login "%B5%C7%A1%A1%C2%BC" "http://172.30.255.2/a30.htm"
		#echo 172
		sleep 5
		continue 2
	    fi
	done < <(echo "$ETH_GATEWAY_MACs_NOW"| tr ' ' '\n') #MAC are seperated with return

	# ========================== ethernet END ================================

    done
}
#get_router_mac
main
