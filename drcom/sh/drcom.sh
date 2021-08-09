#!/usr/bin/sh

CARDID='xxxxxx'
PASSWORD='xxxxxx'

AP_ADP1='wlp5s0'
AP_ADP2='wlan0'

Eth_ADP1='enp4s0'
Eth_ADP2='eth0'

# connect to 192
AP_SZU_WLAN="SZU_WLAN"

# connect to 172
AP_SZU_NewFi="SZU_NewFi"

# connect to 172
MASKDORMITORY="24"

drcom_login(){
    # Usage: drcom_login 0MKKey login_url
    pinginfo=$(ping -c 1 -W 1 baidu.com |grep " 0% packet loss")
    # pinginfo='' # for test
    #empty when not connected
    if [ -z "$pinginfo" ]; then
	/usr/bin/curl -d "DDDDD=$CARDID" -d "upass=$PASSWORD" -d "0MKKey=$1" "$2" #> /dev/null 2>& 1
	#echo a
    fi
}


while true
do
    APNOW1=$(iw dev $AP_ADP1 info 2> /dev/null |sed -n 's/\tssid\ \(.*\)/\1/p')
    APNOW2=$(iw dev $AP_ADP2 info 2> /dev/null |sed -n 's/\tssid\ \(.*\)/\1/p')
    APNOW="$APNOW1:$APNOW2"
    #APNOW="$APNOW1:$APNOW2:$APNOW3" .etc
    # Remove matching prefix pattern.
    APNOW=${APNOW%%:*}
    # Remove matching suffix pattern.
    APNOW=${APNOW##:*}
    # man bash ${parameter#word}

    Eth_MASKNOW1=$(ip -br -4 addr show dev $Eth_ADP1 2> /dev/null |awk '{print $3}'|awk -F "/" '{print $2}')
    Eth_MASKNOW2=$(ip -br -4 addr show dev $Eth_ADP2 2> /dev/null |awk '{print $3}'|awk -F "/" '{print $2}')
    Eth_MASKNOW="$Eth_MASKNOW1:$Eth_MASKNOW2"
    Eth_MASKNOW=${Eth_MASKNOW%%:*}
    Eth_MASKNOW=${Eth_MASKNOW##:*}


    # The two ifs are classified according to the login url
    # connect to 192
    if [[ ":$AP_SZU_WLAN:" =~ :"$APNOW": ]]; then # APNOW contains WLAN_SZU ; 
	# same as  [[ ":$AP_SZU_WLAN:" =~ .*:"$APNOW":.* ]]
	drcom_login "123456" "http://192.168.255.235/a70.htm"
	# drcom_login "123456" "http://drcom.szu.edu.cn/a70.htm"
	continue
    fi

    # connect to 172
    if [[ ":$AP_SZU_NewFi:" =~ :"$APNOW": ]] ||
	[[ ":$MASKDORMITORY:" =~ :"$Eth_MASKNOW": ]]; then
	    drcom_login "%B5%C7%A1%A1%C2%BC" "http://172.30.255.2/a30.htm"
	    continue
    fi
    sleep 5
done
