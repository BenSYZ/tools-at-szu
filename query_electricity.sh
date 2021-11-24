#!/bin/bash

# get from curl
dormitory=1632
roomId=8780

# Send an email when the battery is below 20
mail_threshold=20
mail_address=<mail address>

today=$(date -d today +%Y-%m-%d)
three_days_ago=$(date -d 3-days-ago +%Y-%m-%d)

today_y=$(date -d today +%Y)
three_days_ago_y=$(date -d 3-days-ago +%Y)

#echo $three_days_ago
#echo $today

html=$(curl -s \
	-d "beginTime=$three_days_ago" \
	-d "endTime=$today" \
	-d "type=2" \
	-d "roomId=$roomId" \
	-d "roomName=$dormitory                " \
	-d "client=192.168.84.110" \
	http://192.168.84.3:9090/cgcSims/selectList.do)

# parse HTML
electric_info=$(sed 's/\r//g;s/^[ \t]*//g;/^[[:space:]]*$/d' <(echo "$html") |\
    grep -a -v '[<>]' |\
    awk -v dormitory=$dormitory -v today_y="$today_y" -v three_days_ago_y="$three_days_ago_y" '($0~dormitory),($0~today_y||$0~three_days_ago_y){print $0}')
    #  remove \r space return
    # remove html tags 
    # print between dormitory and year # grammar: comma

# send mail
mail_info=$(tac <(echo "$electric_info") |awk 'NR==1{print "更新时间：" $0};NR==4{print "剩余电量：" $0}')
#electric_reserve=$(tac <(echo "$electric_info") |awk 'NR==4{print $0}')
#echo $mail_info

#echo $electric_reserve
: ${electric_reserve:=$(($mail_threshold+1))}
#echo $electric_reserve
#electric_reserve=$(sed 's/\r//' <<<$(echo "$electric_reserve")) #remove the \r

if [ "$(bc <<<$(echo -e "$electric_reserve < $mail_threshold"))" -eq 1 ]; then
	echo -e "Subject: 宿舍电费\n\n$mail_info\n记得及时充电费哦. \n\nRaspberrypi\n$(date)" | sendmail $mail_address
fi
