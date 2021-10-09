#!/usr/bin/sh

CARDID='xxxxxx'
PASSWORD='xxxxxx'

# Wireless network card adapter
AP_ADPs='wlp5s0'
# sepreate with colon :
#AP_ADPs='wlp5s0:wlan0'

# Wired network card
ETH_ADPs='enp4s0'
# sepreate with colon :
#ETH_ADPs='enp4s0:eth0'

# get the names of all the adapters by:
# ip a
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

# modify the following line with the mac address of the Ethernet router which needs to log in with "172.30.255.2/a30.htm"
ETH_GATEWAY_MACs_172="xx:xx:xx:xx:xx:xx"
# sepreate with SPACE
#ETH_GATEWAY_MACs_172="xx:xx:xx:xx:xx:xx xx:xx:xx:xx:xx:xx"

# get the mac address of gateway by uncomment the last `get_router_mac`



get_router_mac(){
    # sep with space
    ETH_GATEWAY_MACs_NOW=""
    while read ETH_ADP; do
	ETH_GATEWAY_MACs_NOW="$ETH_GATEWAY_MACs_NOW $(arp -i "$ETH_ADP" |awk 'NR>=2 {print $3}' | tr '\n' ' ')"
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
	# sep with colon
	APs_NOW=""
	while read AP_ADP; do
	    APs_NOW="$APs_NOW:$(iw dev "$AP_ADP" info 2> /dev/null |sed -n 's/\tssid\ \(.*\)/\1/p')"
	done < <(echo "$AP_ADPs" | tr ':' '\n')
	APs_NOW="$(echo $APs_NOW|sed 's/^:*//;s/:*$//')"
	#echo $APs_NOW

	# login
	while read AP_NOW; do
	    #echo line="$AP_NOW";
	    if [[ ":$APs_192:" =~ :"$AP_NOW": ]]; then # AP_NOW in $AP_192 ; ref: /etc/profile append_path()
		# same as  [[ ":$APs_192:" =~ .*:"$AP_NOW":.* ]]
		#echo 192
		drcom_login "123456" "https://drcom.szu.edu.cn/a70.htm"
		sleep 5
		continue 2
	    elif [[ ":$APs_172:" =~ :"$AP_NOW": ]]; then
		#echo 172
		drcom_login "%B5%C7%A1%A1%C2%BC" "http://172.30.255.2/a30.htm"
		sleep 5
		continue 2
	    fi
	done < <(echo "$APs_NOW" | tr ':' '\n')
	# ========================== wireless END ================================
	# ========================== ethernet BEGIN ================================
	# sep with space
	ETH_GATEWAY_MACs_NOW=""
	while read ETH_ADP; do
	    ETH_GATEWAY_MACs_NOW="$ETH_GATEWAY_MACs_NOW $(arp -i "$ETH_ADP" |awk 'NR>=2 {print $3}')"
	done < <(echo "$ETH_ADPs" | tr ':' '\n')
	ETH_GATEWAY_MACs_NOW="$(echo $ETH_GATEWAY_MACs_NOW|xargs)"
	#echo "$ETH_GATEWAY_MACs_NOW"

	# login
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
	done < <(echo "$GATEWAY_MACs_NOW"| tr ' ' '\n')
	# ========================== ethernet END ================================
	sleep 5
    done
}

#get_router_mac
main
