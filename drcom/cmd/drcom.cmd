echo off

rem LANG=en_US
rem used in findstr mask
chcp 437
rem chcp 936 zh_CN


rem =============Modify the following===========
set CARDID=xxxxxx
set PASSWORD=xxxxxx

set AP_SZU_WLAN=SZU_WLAN
set AP_SZU_NewFi=SZU_NewFi

set Ethernet_Name=以太网
rem set Ethernet_Name=NAT
set MASK_DORMITORY=255.255.255.0
rem ============================================

rem setlocal enabledelayedexpansion

:loop
	rem ===================== wifi part =======================
	set APNOW=

	for /f "tokens=3" %%i in ('netsh wlan show interfaces ^| findstr "SSID" ^|findstr %AP_SZU_WLAN%') do set APNOW=%%i
	for /f "tokens=3" %%i in ('netsh wlan show interfaces ^| findstr "SSID" ^|findstr %AP_SZU_NewFi%') do set APNOW=%APNOW% %%i
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
			if "%APNOW%" == "%AP_SZU_WLAN%" (
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

	netsh interface ip show address name="%Ethernet_Name%" |findstr mask > .\ethernetinfo.log
	for /f "tokens=5" %%i in (.\ethernetinfo.log) do set MASK_NOW=%%i
	rem remove the last parentheses
	set MASK_NOW=%MASK_NOW:~0,-1%
	rem echo %MASK_NOW%

	rem I don't kown why the following not work
	rem for /f "tokens=1-10" %%i in ('netsh interface ip show address name="%%Ethernet_Name%%"') do echo %%i %%j %%k %%l %%m %%n %%o %%p


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
