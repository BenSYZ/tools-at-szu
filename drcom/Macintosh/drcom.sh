#!/bin/zsh

CARDID='xxxxxx'
PASSWORD='xxxxxx'

# sepreate with colon :

AP_ADPs='wlp5s0:wlan0'

# get the names of all the adapters by:
#networksetup -listallhardwareports
# device name is like en0 en1 .etc
# if the Hardware Port is not or are not only "Thunderbolt Ethernet", modify the following lines
Eth_ADPs=''
Eth_ADPs="$Eth_ADPs:$(networksetup -listallhardwareports |grep "Thunderbolt Ethernet" -A 1 |awk '{if (NR==2){print $2}}')"

# Remove matching prefix pattern.
Eth_ADPs=${Eth_ADPs%%:}
# Remove matching suffix pattern.
Eth_ADPs=${Eth_ADPs##:}

# connect to 192
APs_192="SZU_WLAN"
#APs_192="SZU_WLAN:xxxxxx"

# connect to 172
APs_172="SZU_NewFi"
#APs_172="SZU_NewFi:xxxxx"

# SZU_Eth mask
# Cannot distinguish which site should I log in by mask 
Eth_MASKs="255.255.255.0"

drcom_login(){
    # Usage: drcom_login 0MKKey login_url
    pinginfo=$(ping -c 1 -W 1 baidu.com |grep " 0% packet loss")

    # pinginfo='' # for test
    #empty when not connected
    if [ -z "$pinginfo" ]; then
	if [ -n "$1" ];then
	    # $1 $2 were assigned
	    /usr/bin/curl -d "DDDDD=$CARDID" -d "upass=$PASSWORD" -d "0MKKey=$1" "$2" > /dev/null 2>& 1
	    #echo a
	else
	    # default, used for ethernet connection
	    # $1 $2 were empty, ping drcom.szu.edu.cn first if not connect to 172
	    pinginfo=$(ping -c 1 -W 1 drcom.szu.edu.cn |grep " 0% packet loss")
	    if [ -z "$pinginfo" ]; then
		# drcom ping successful
		#echo default drcom
		/usr/bin/curl -d "DDDDD=$CARDID" -d "upass=$PASSWORD" -d "0MKKey=123456" "https://drcom.szu.edu.cn" > /dev/null 2>& 1
	    else
		/usr/bin/curl -d "DDDDD=$CARDID" -d "upass=$PASSWORD" -d "%B5%C7%A1%A1%C2%BC" "http://172.30.255.2/a30.htm" > /dev/null 2>& 1
	    fi
	fi
    fi
}


while true
do
    sleep 5

    APNOWs=""
    #while read AP_ADP; do
    #    APNOWs="$APNOWs:$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I |sed -n 's/ \{11\}SSID: \(.*\)/\1/p')"
    #    #APNOWs="$APNOWs:$(iw dev $AP_ADP info 2> /dev/null |sed -n 's/\tssid\ \(.*\)/\1/p')"
    #    #echo $APNOWs
    #done < <(echo "$AP_ADPs" | tr ':' '\n')
    APNOWs="$APNOWs:$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I |sed -n 's/ \{11\}SSID: \(.*\)/\1/p')"
    # Remove matching prefix pattern.
    APNOWs=${APNOWs%%:}
    # Remove matching suffix pattern.
    APNOWs=${APNOWs##:}
    # man bash ${parameter#word}
    #echo $APNOWs

    Eth_MASKNOWs=""
    while read Eth_ADP; do
	Eth_MASKNOWs="$Eth_MASKNOWs:$( ipconfig getoption $Eth_ADP subnet_mask )"
    done < <(echo "$Eth_ADPs" | tr ':' '\n')
    Eth_MASKNOWs=${Eth_MASKNOWs%%:}
    Eth_MASKNOWs=${Eth_MASKNOWs##:}
    #echo $Eth_MASKNOWs


    # The two ifs are classified according to the login url
    # connect to 192
    # https://stackoverflow.com/questions/27702452/loop-through-a-comma-separated-shell-variable

    while read APNOW; do
	#echo line="$APNOW";
	if [[ ":$APs_192:" =~ :"$APNOW": ]]; then # APNOW in $AP_192 ; ref: /etc/profile append_path()
	    # same as  [[ ":$APs_192:" =~ .*:"$APNOW":.* ]]
	    #echo 1
	    drcom_login "123456" "http://192.168.255.235/a70.htm"
	    # drcom_login "123456" "http://drcom.szu.edu.cn/a70.htm"
	    continue
	elif [[ ":$APs_172:" =~ :"$APNOW": ]]; then
	    #echo 2
	    drcom_login "%B5%C7%A1%A1%C2%BC" "http://172.30.255.2/a30.htm"
	    continue
	fi
    done < <(echo "$APNOWs" | tr ':' '\n')


    while read MASKNOW; do
	if [[ ":$MASKNOW:" =~ :"$Eth_MASKs": ]]; then
	    echo 0
	    drcom_login
	    continue
	fi
    done < <(echo "$Eth_MASKNOWs" | tr ':' '\n')
done
