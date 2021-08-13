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

# connect to "drcom.szu.edu.cn"
APs_192="SZU_WLAN"
# sepreate with colon :
#APs_192="SZU_WLAN:xxxxxx"

# connect to "172.30.255.2/a30.htm"
APs_172="SZU_NewFi"
# sepreate with colon :
#APs_172="SZU_NewFi:xxxxx"

# SZU_Eth mask
# Cannot distinguish which site should I log in by mask 
Eth_MASKs="255.255.255.0"

drcom_login(){
    # Usage: drcom_login 0MKKey login_url
    pinginfo="$(ping -c 1 -W 1 baidu.com |grep " 0% packet loss")"

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

    APs_NOW=""
    #while read AP_ADP; do
    #    APs_NOW="$APs_NOW:$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I |sed -n 's/ \{11\}SSID: \(.*\)/\1/p')"
    #    #APs_NOW="$APs_NOW:$(iw dev $AP_ADP info 2> /dev/null |sed -n 's/\tssid\ \(.*\)/\1/p')"
    #    #echo $APs_NOW
    #done < <(echo "$AP_ADPs" | tr ':' '\n')
    APs_NOW="$APs_NOW:$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I |sed -n 's/ \{11\}SSID: \(.*\)/\1/p')"
    # Remove matching prefix pattern.
    APs_NOW=${APs_NOW%%:}
    # Remove matching suffix pattern.
    APs_NOW=${APs_NOW##:}
    # man bash ${parameter#word}
    #echo $APs_NOW

    Eth_MASKs_NOW=""
    while read Eth_ADP; do
	Eth_MASKs_NOW="$Eth_MASKs_NOW:$( ipconfig getoption $Eth_ADP subnet_mask )"
    done < <(echo "$Eth_ADPs" | tr ':' '\n')
    Eth_MASKs_NOW=${Eth_MASKs_NOW%%:}
    Eth_MASKs_NOW=${Eth_MASKs_NOW##:}
    #echo $Eth_MASKs_NOW


    # The two ifs are classified according to the login url
    # connect to "drcom.szu.edu.cn"
    # https://stackoverflow.com/questions/27702452/loop-through-a-comma-separated-shell-variable

    while read AP_NOW; do
	#echo line="$AP_NOW";
	if [[ ":$APs_192:" =~ :"$AP_NOW": ]]; then # AP_NOW in $AP_192 ; ref: /etc/profile append_path()
	    # same as  [[ ":$APs_192:" =~ .*:"$AP_NOW":.* ]]
	    #echo 1
	    drcom_login "123456" "http://192.168.255.235/a70.htm"
	    # drcom_login "123456" "http://drcom.szu.edu.cn/a70.htm"
	    continue
	elif [[ ":$APs_172:" =~ :"$AP_NOW": ]]; then
	    #echo 2
	    drcom_login "%B5%C7%A1%A1%C2%BC" "http://172.30.255.2/a30.htm"
	    continue
	fi
    done < <(echo "$APs_NOW" | tr ':' '\n')


    while read MASK_NOW; do
	if [[ ":$MASK_NOW:" =~ :"$Eth_MASKs": ]]; then
	    echo 0
	    drcom_login
	    continue
	fi
    done < <(echo "$Eth_MASKs_NOW" | tr ':' '\n')
done
