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
ROUTER_MACs_192="xx:xx:xx:xx:xx:xx"
# sepreate with space
#ROUTER_MAC_192="xx:xx:xx:xx:xx:xx xx:xx:xx:xx:xx:xx"

# SZU_Eth mask
# modify the following line with the mac address of the Ethernet router which needs to log in with "172.30.255.2/a30.htm"
ROUTER_MACs_172="xx:xx:xx:xx:xx:xx"
# sepreate with space
#ROUTER_MAC_172="xx:xx:xx:xx:xx:xx xx:xx:xx:xx:xx:xx"

get_router_mac(){
    # sep with space
    ROUTER_MACs_NOW=""
    while read ETH_ADP; do
	ROUTER_MACs_NOW="$ROUTER_MACs_NOW $(arp -i "$ETH_ADP" |awk 'NR>=2 {print $3}' | tr '\n' ' ')"
    done < <(echo "$ETH_ADPs" | tr ':' '\n')
    ROUTER_MACs_NOW="$(echo $ROUTER_MACs_NOW|xargs)"
    echo "$ROUTER_MACs_NOW"
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
	APs_NOW=$(echo $APs_NOW|sed 's/^:*//;s/:*$//')
	#echo $APs_NOW

	# sep with space
	ROUTER_MACs_NOW=""
	while read ETH_ADP; do
	    ROUTER_MACs_NOW="$ROUTER_MACs_NOW $(arp -i "$ETH_ADP" |awk 'NR>=2 {print $3}')"
	done < <(echo "$ETH_ADPs" | tr ':' '\n')
	ROUTER_MACs_NOW="$(echo $ROUTER_MACs_NOW|xargs)"
	#echo $ROUTER_MACs_NOW


	while read AP_NOW; do
	    #echo line="$AP_NOW";
	    if [[ ":$APs_192:" =~ :"$AP_NOW": ]]; then # AP_NOW in $AP_192 ; ref: /etc/profile append_path()
		# same as  [[ ":$APs_192:" =~ .*:"$AP_NOW":.* ]]
		drcom_login "123456" "https://drcom.szu.edu.cn/a70.htm"
		# drcom_login "123456" "http://drcom.szu.edu.cn/a70.htm"
		continue
	    elif [[ ":$APs_172:" =~ :"$AP_NOW": ]]; then
		drcom_login "%B5%C7%A1%A1%C2%BC" "http://172.30.255.2/a30.htm"
		continue
	    fi
	done < <(echo "$APs_NOW" | tr ':' '\n')

	while read ROUTER_MAC_NOW; do
	    #echo line="$AP_NOW";
	    if [[ "$ROUTER_MACs_192" =~ "$ROUTER_MAC_NOW" ]]; then # AP_NOW in $AP_192 ; ref: /etc/profile append_path()
		drcom_login "123456" "https://drcom.szu.edu.cn/a70.htm"
		#echo 192
		continue
	    elif [[ "$ROUTER_MACs_172" =~ "$ROUTER_MAC_NOW" ]]; then
		drcom_login "%B5%C7%A1%A1%C2%BC" "http://172.30.255.2/a30.htm"
		#echo 172
		continue
	    fi
	done < <(echo "$ROUTER_MACs_NOW") #MAC are seperated with space
    done
}

#get_router_mac
main
