#!/usr/bin/sh

CARDID='xxxxxx'
PASSWORD='xxxxxx'

# Wireless network card adapter
AP_ADPs='wlp5s0'
# sepreate with colon :
#AP_ADPs='wlp5s0:wlan0'

# Wired network card
# sepreate with colon :
ETH_ADPs='enp4s0:eth0'

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
GATEWAY_MACs_192="xx:xx:xx:xx:xx:xx"
# sepreate with space
#GATEWAY_MAC_192="xx:xx:xx:xx:xx:xx xx:xx:xx:xx:xx:xx"

# modify the following line with the mac address of the Ethernet router which needs to log in with "172.30.255.2/a30.htm"
GATEWAY_MACs_172="xx:xx:xx:xx:xx:xx"
# sepreate with space
#GATEWAY_MAC_172="xx:xx:xx:xx:xx:xx xx:xx:xx:xx:xx:xx"

get_router_mac(){
    # sep with space
    GATEWAY_MACs_NOW=""
    while read ETH_ADP; do
	GATEWAY_IP_NOW="$(ip -4 route list |grep "$ETH_ADP" | grep default |cut -d ' ' -f 3)"
	if [ -n "$GATEWAY_IP_NOW" ];then
	    GATEWAY_MACs_NOW="$GATEWAY_MACs_NOW $(ip neigh | grep "$GATEWAY_IP_NOW" |awk '{print $5}')"
	fi
    done < <(echo "$ETH_ADPs" | tr ':' '\n')
    GATEWAY_MACs_NOW="$(echo $GATEWAY_MACs_NOW|xargs)" # removing the prefix and suffix space
    echo "$GATEWAY_MACs_NOW"
}

drcom_login(){
    # Usage: drcom_login 0MKKey login_url
    pinginfo="$(ping -c 1 -W 1 baidu.com |grep " 0% packet loss")"

    # pinginfo='' # for test
    #empty when not connected
    if [ -z "$pinginfo" ]; then
	/usr/bin/curl -d "DDDDD=$CARDID" -d "upass=$PASSWORD" -d "0MKKey=$1" "$2" > /dev/null 2>& 1
    fi
}

main(){
    while true
    do
	sleep 5

	# sep with colon
	APs_NOW=""
	while read AP_ADP; do
	    APs_NOW="$APs_NOW:$(iw dev "$AP_ADP" info 2> /dev/null |sed -n 's/\tssid\ \(.*\)/\1/p')"
	done < <(echo "$AP_ADPs" | tr ':' '\n')
	APs_NOW="$(echo $APs_NOW|sed 's/^:*//;s/:*$//')"
	#echo $APs_NOW

	# sep with space
	GATEWAY_MACs_NOW=""
	while read ETH_ADP; do
	    GATEWAY_IP_NOW="$(ip -4 route list |grep "$ETH_ADP" | grep default |cut -d ' ' -f 3)"
	    if [ -n "$GATEWAY_IP_NOW" ];then
		GATEWAY_MACs_NOW="$GATEWAY_MACs_NOW $(ip neigh | grep "$GATEWAY_IP_NOW" |awk '{print $5}')"
	    fi
	done < <(echo "$ETH_ADPs" | tr ':' '\n')
	GATEWAY_MACs_NOW="$(echo $GATEWAY_MACs_NOW|xargs)" # removing the prefix and suffix space
	#echo "$GATEWAY_MACs_NOW"

	# login
	while read AP_NOW; do
	    #echo line="$AP_NOW";
	    if [[ ":$APs_192:" =~ :"$AP_NOW": ]]; then # AP_NOW in $AP_192 ; ref: /etc/profile append_path()
		# same as  [[ ":$APs_192:" =~ .*:"$AP_NOW":.* ]]
		#echo 1
		drcom_login "123456" "https://drcom.szu.edu.cn/a70.htm"
		continue 2
	    elif [[ ":$APs_172:" =~ :"$AP_NOW": ]]; then
		#echo 2
		drcom_login "%B5%C7%A1%A1%C2%BC" "http://172.30.255.2/a30.htm"
		continue 2
	    fi
	done < <(echo "$APs_NOW" | tr ':' '\n')

	while read GATEWAY_MAC_NOW; do
	    #echo line="$GATEWAY_MAC_NOW";
	    if [[ "$GATEWAY_MACs_192" =~ "$GATEWAY_MAC_NOW" ]]; then # AP_NOW in $AP_192 ; ref: /etc/profile append_path()
		drcom_login "123456" "https://drcom.szu.edu.cn/a70.htm"
		#echo 192
		continue 2
	    elif [[ "$GATEWAY_MACs_172" =~ "$GATEWAY_MAC_NOW" ]]; then
		drcom_login "%B5%C7%A1%A1%C2%BC" "http://172.30.255.2/a30.htm"
		#echo 172
		continue 2
	    fi
	done < <(echo "$GATEWAY_MACs_NOW"| tr ' ' '\n')

    done
}

get_router_mac
#main
