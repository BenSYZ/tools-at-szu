@echo off

chcp 437 > nul

rem LANG=en_US
rem used in findstr mask
rem Ethernet use zh still worked
::chcp 936 zh_CN


rem =============Modify the following===========
set CARDID=xxxxxx
set PASSWORD=xxxxxx

rem not use wireless network card adapter to capture the wifi name.

rem Wired network card
rem sepreate with comma :
set ETH_ADPs=以太网

rem get the names of all the adapters by:
::ipconfig

rem connect to "drcom.szu.edu.cn"
set "APs_192=SZU_WLAN:401:rasp:Misaka Network:ttt:401"
rem sepreate with comma :
rem at most 26
::set APs_192="SZU_WLAN:xxxxxx"

rem connect to "172.30.255.2/a30.htm"
set APs_172="SZU_NewFi"
rem sepreate with comma :
::set APs_172="SZU_NewFi:xxxxx"

rem modify the following line with the mac address of the Ethernet router which needs to log in with "drcom.szu.edu.cn"
rem you can get the mac_address with "get_router_mac" function by uncomment get_router_mac at last
set GATEWAY_MACs_192="xx:xx:xx:xx:xx:xx"
rem sepreate with space
::set GATEWAY_MAC_192="xx:xx:xx:xx:xx:xx xx:xx:xx:xx:xx:xx"

rem modify the following line with the mac address of the Ethernet router which needs to log in with "172.30.255.2/a30.htm"
set GATEWAY_MACs_172="xx:xx:xx:xx:xx:xx"
rem sepreate with space
::set GATEWAY_MAC_172="xx:xx:xx:xx:xx:xx xx:xx:xx:xx:xx:xx"

set GATEWAY_MACs_192=xx:xx:xx:xx:xx:xx
set GATEWAY_MACs_172=xx:xx:xx:xx:xx:xx
rem ============================================



setlocal EnableDelayedExpansion

set LF=^


rem two lines are LF

set "APs_192=%APs_192::=!LF!%"

rem Get APs_NOW
set "APs_NOW="
for /f "delims=*" %%a in ( "!APs_192!" ) do (
	::echo %%a
	for /f "tokens=3*" %%A in ('netsh wlan show interfaces ^| findstr "SSID" ^|findstr -v "%%a"') do (
		rem if empty return, program not will not go into for loop, so I need to remove the first :
		set "APs_NOW=!APs_NOW!:%%A"
	)
)

rem remove the first comma
echo %APs_NOW:~1%

set "APs_NOW=%APs_NOW::=!LF!%"
for /f "delims=*" %%a in ( "!APs_NOW!" ) do (
	echo %%a
)

