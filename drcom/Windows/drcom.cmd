echo off

chcp 437
rem LANG=en_US
rem used in findstr mask
rem Ethernet use zh still worked
::chcp 936 zh_CN


rem =============Modify the following===========
set CARDID=xxxxxx
set PASSWORD=xxxxxx

rem not use wireless network card adapter to capture the wifi name.

rem Wired network card
rem sepreate with colon :
set ETH_ADPs=以太网

rem get the names of all the adapters by:
::ipconfig

rem connect to "drcom.szu.edu.cn"
set "APs_192=SZU_WLAN 401"
rem sepreate with colon :
::set APs_192="SZU_WLAN:xxxxxx"

rem connect to "172.30.255.2/a30.htm"
set APs_172="SZU_NewFi"
rem sepreate with colon :
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


rem setlocal enabledelayedexpansion

:loop
	rem ===================== wifi part =======================
	::timeout 5 > nul 2> nul
	set APNOW=

	for /f "tokens=3" %%i in ('netsh wlan show interfaces ^| findstr "SSID" ^|findstr %APs_192%') do set APNOW=%%i
	for /f "tokens=3" %%i in ('netsh wlan show interfaces ^| findstr "SSID" ^|findstr %APs_172%') do set APNOW=%APNOW% %%i
	if not "%APNOW%" == "" (
		rem echo APNOW: %APNOW%
		rem empty when not connected to szu wlan
		set pinginfo=
		for /f %%i in ('ping /n 1 /w 5 baidu.com ^| findstr /c:"(0%% loss)"') do set pinginfo=%%i
		echo pinginfo: %pinginfo%

		rem empty when not logined
		rem <test>: set pinginfo=
		rem echo "%APNOW%"
		rem echo %pinginfo%
		if "%pinginfo%" == "" (
			echo try to login
			if "%APNOW%" == "%APs_192%" (
				rem echo szu
				curl -d "DDDDD=%CARDID%" -d "upass=%PASSWORD%" -d "0MKKey=123456" http://192.168.255.235/a70.htm > nul 2> nul
			) else (
				rem echo new
				curl -d "DDDDD=%CARDID%" -d "upass=%PASSWORD%" -d "0MKKey=%B5%C7%A1%A1%C2%BC" http://172.30.255.2/a30.htm > nul 2> nul
			)
		)
		timeout 5 > nul 2> nul
		goto loop
	)

	rem ===================== ethernet part =======================
	set MASK_NOW=

	netsh interface ip show address name="%ETH_ADPs%" |findstr mask > .\ethernetinfo.log
	for /f "tokens=5" %%i in (.\ethernetinfo.log) do set MASK_NOW=%%i
	rem remove the last parentheses
	set MASK_NOW=%MASK_NOW:~0,-1%
	rem echo %MASK_NOW%

	rem I don't kown why the following not work
	rem for /f "tokens=1-10" %%i in ('netsh interface ip show address name="%%ETH_ADPs%%"') do echo %%i %%j %%k %%l %%m %%n %%o %%p


	if not "%MASK_NOW%" == "" (
	    set pinginfo=
	    for /f %%i in ('ping /n 1 /w 2 baidu.com ^| findstr /c:"(0%% loss)"') do set pinginfo=%%i
	    rem echo Mask pinginfo: %pinginfo%

	    rem empty when not logined
	    rem echo Mask pinginfo: %pinginfo%
	    if "%pinginfo%" == "" (
		rem echo test
		curl -d "DDDDD=%CARDID%" -d "upass=%PASSWORD%" -d "0MKKey=%B5%C7%A1%A1%C2%BC" http://172.30.255.2/a30.htm > nul 2> nul
	    )
	)

    timeout 5 > nul 2> nul
goto loop
