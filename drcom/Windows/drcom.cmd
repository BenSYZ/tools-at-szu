@echo off

chcp  65001> nul

rem LANG=en_US
rem used in findstr mask
rem Ethernet use zh still worked
::chcp 936 zh_CN


rem =============Modify the following===========
set "CARDID=xxxxxx"
set "PASSWORD=xxxxxx"

rem not use wireless network card adapter to capture the wifi name.

rem Wired network card
set "ETH_ADPs=以太网"

rem get the names of all the adapters by:
::ipconfig

rem connect to "drcom.szu.edu.cn"
set "APs_192=SZU_WLAN"
rem sepreate with colon :
rem at most 26
::set APs_192="SZU_WLAN:xxxxxx"

rem connect to "172.30.255.2/a30.htm"
set "APs_172=SZU_NewFi"
rem sepreate with colon :
rem at most 26
::set APs_172="SZU_NewFi:xxxxx"

rem modify the following line with the mac address of the Ethernet router which needs to log in with "drcom.szu.edu.cn"
set "ETH_GATEWAY_MACs_192=xx-xx-xx-xx-xx-xx"
rem sepreate with colon :
::set "ETH_GATEWAY_MAC_192=xx-xx-xx-xx-xx-xx:xx-xx-xx-xx-xx-xx"

rem modify the following line with the mac address of the Ethernet router which needs to log in with "172.30.255.2/a30.htm"
set "ETH_GATEWAY_MACs_172=xx-xx-xx-xx-xx-xx"
rem sepreate with colon :
::set "ETH_GATEWAY_MAC_172=xx-xx-xx-xx-xx-xx:xx-xx-xx-xx-xx-xx"

rem ues the following 2 lines to get the ethernet gateway mac
rem rem Uncomment the leading ::
::for /f "tokens=3 delims= " %%a in ('netsh interface ip show addresses "以太网" ^|findstr /c:"Default Gateway"') do set "ETH_GATEWAY_IP=%%a"
::echo %ETH_GATEWAY_IP%
::for /f "tokens=2 delims= " %%a in ( 'arp /a "%ETH_GATEWAY_IP%" ^|findstr dynamic' ) do set "ETH_GATEWAY_MAC=%%a"
::echo %ETH_GATEWAY_MAC%


rem ========================== Config END ============================



setlocal EnableDelayedExpansion

set LF=^


rem two lines are LF

set "APs_192=%APs_192::=!LF!%"
set "APs_172=%APs_172::=!LF!%"
set "ETH_GATEWAY_MACs_192=%ETH_GATEWAY_MACs_192::=!LF!%"
set "ETH_GATEWAY_MACs_172=%ETH_GATEWAY_MACs_172::=!LF!%"


:loop
rem ========================== wireless BEGIN ==============================
::timeout 5 > nul 2> nul
for /f "tokens=3*" %%A in ('netsh wlan show interfaces ^| findstr "SSID" ^|findstr -v "BSSID"') do (
	::echo %%a
	for /f "delims=*" %%a in ( "!APs_192!" ) do (
		rem if empty return, program not will not go into for loop, so I need to remove the first :
		if /I "%%a"=="%%A" (
		rem To avoid that %%a in %%A
		rem ping and curl
			::echo in 192
			set "pinginfo="
			for /f %%i in ('ping /n 1 /w 5 baidu.com ^| findstr /c:"(0%% loss)"') do set "pinginfo=%%i"
			::echo pinginfo: !pinginfo!
			rem empty when not logined
			rem <test>: set pinginfo=
			::echo %pinginfo%
			if "!pinginfo!"=="" (
				echo try to login 192
				curl -d "DDDDD=%CARDID%" -d "upass=%PASSWORD%" -d "0MKKey=123456" http://drcom.szu.edu.cn/a70.htm > nul 2> nul
				echo ===
			)
			rem use ping to timeout
			ping /n 5 127.0.0.1 > nul
			goto loop
		)
	)

	::echo %%a
	for /f "delims=*" %%a in ( "!APs_172!" ) do (
		rem if empty return, program not will not go into for loop, so I need to remove the first :
		if /I "%%a"=="%%A" (
			::echo in 172
			set "pinginfo="
			for /f %%i in ('ping /n 1 /w 5 baidu.com ^| findstr /c:"(0%% loss)"') do set "pinginfo=%%i"
			::echo pinginfo: !pinginfo!
			rem empty when not logined
			rem <test>: set pinginfo=
			::echo !pinginfo!
			if "!pinginfo!" == "" (
				echo try to login 172
				curl -d "DDDDD=%CARDID%" -d "upass=%PASSWORD%" -d "0MKKey=%%B5%%C7%%A1%%A1%%C2%%BC" "http://172.30.255.2/a30.htm" > nul 2> nul
				echo ===
			)
			rem use ping to timeout
			ping /n 5 127.0.0.1 > nul
			goto loop
		)
	)
)

rem ========================== wireless END ================================


::if "APs_NOW_IN_172"
::
::
::set "APs_NOW=%APs_NOW::=!LF!%"
::for /f "delims=*" %%a in ( "!APs_NOW!" ) do (
::	echo %%a
::)
::arp /a "192.168.33.33" |findstr dynamic
::netsh interface ip show addresses "%ETH_ADPs%" |findstr /c:"Default Gateway"

rem ========================== ethernet START ================================

for /f "tokens=3 delims= " %%a in ('netsh interface ip show addresses "%ETH_ADPs%" ^|findstr /c:"Default Gateway"') do set "ETH_GATEWAY_IP=%%a"
::echo %ETH_GATEWAY_IP%
for /f "tokens=2 delims= " %%a in ( 'arp /a "%ETH_GATEWAY_IP%" ^|findstr dynamic' ) do set "ETH_GATEWAY_MAC=%%a"


for /f "delims=*" %%A in ( "%ETH_GATEWAY_MAC%" ) do (
	::echo %%A
	for /f "delims=*" %%a in ( "%ETH_GATEWAY_MACs_192%" ) do (
		::echo %%a
		rem if empty return, program not will not go into for loop, so I need to remove the first :
		if /I "%%a"=="%%A" (
		rem To avoid that %%a in %%A
		rem ping and curl
			::echo in 192
			set "pinginfo="
			for /f %%i in ('ping /n 1 /w 10 baidu.com ^| findstr /c:"(0%% loss)"') do set "pinginfo=%%i"
			::echo pinginfo: !pinginfo!
			rem empty when not logined
			rem <test>: set pinginfo=
			::echo %pinginfo%
			if "!pinginfo!"=="" (
				echo try to login 192
				curl -d "DDDDD=%CARDID%" -d "upass=%PASSWORD%" -d "0MKKey=123456" "http://drcom.szu.edu.cn/a70.htm" > nul 2> nul
				echo ===
			)
			rem use ping to timeout
			ping /n 5 127.0.0.1 > nul
			goto loop
		)
	)
)


for /f "delims=*" %%A in ( "%ETH_GATEWAY_MAC%" ) do (
	::echo %%A
	for /f "delims=*" %%a in ( "%ETH_GATEWAY_MACs_172%" ) do (
		::echo %%a
		rem if empty return, program not will not go into for loop, so I need to remove the first :
		if /I "%%a"=="%%A" (
			::echo in 172
			set "pinginfo="
			for /f %%i in ('ping /n 1 /w 10 baidu.com ^| findstr /c:"(0%% loss)"') do set "pinginfo=%%i"
			echo pinginfo: !pinginfo!
			rem empty when not logined
			rem <test>: set pinginfo=
			::echo !pinginfo!
			if "!pinginfo!" == "" (
				echo try to login 172
				curl -d "DDDDD=%CARDID%" -d "upass=%PASSWORD%" -d "0MKKey=%%B5%%C7%%A1%%A1%%C2%%BC" "http://172.30.255.2/a30.htm" > nul 2> nul
				echo ===
			)
			rem use ping to timeout
			ping /n 5 127.0.0.1 > nul
			goto loop
		)
	)
)

rem ========================== ethernet END ================================

ping /n 5 127.0.0.1 > nul
goto loop

