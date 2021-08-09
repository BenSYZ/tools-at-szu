@echo off

setlocal enabledelayedexpansion
curl --version | find /i "Windows" > nul
IF !errorlevel! == 1 (
	echo "Install curl (https://curl.haxx.se/windows/) first."
	goto :end
) else (
	goto :Install
)

:Install

rem rem =============INFO=============
rem set /p account=Please enter the campus card number:
rem set /p password=Please enter the passsword:
rem 
rem mkdir tmp
rem echo @echo off > .\tmp\drcom.cmd
rem echo set account=%account% >> .\tmp\drcom.cmd
rem echo set password=%password% >> .\tmp\drcom.cmd
rem type .\example.cmd >> .\tmp\drcom.cmd

mkdir tmp
copy .\drcom.cmd .\tmp\drcom.cmd

rem =============vbs=============
rem move the drcom.cmd and drcom.vbs to %filepath%, and create a shortcut at Startup directory to autostart
set filepath=C:\Users\%username%\drcom_autologin
echo set ws=WScript.CreateObject("WScript.Shell") >.\tmp\drcom.vbs
echo ws.Run "%filepath%\drcom.cmd /start",0 >>.\tmp\drcom.vbs

mkdir %filepath%

rem =============shortcut=============

set startmenu=C:\Users\%username%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup

echo Set oWS = WScript.CreateObject("WScript.Shell") > CreateShortcut.vbs
echo sLinkFile = "%startmenu%\drcom.vbs.lnk" >> CreateShortcut.vbs
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> CreateShortcut.vbs
echo oLink.TargetPath = "%filepath%\drcom.vbs" >> CreateShortcut.vbs
echo oLink.Save >> CreateShortcut.vbs
cscript.exe /nologo CreateShortcut.vbs
del CreateShortcut.vbs

rem =============move=============
move .\tmp\drcom.cmd %filepath% > nul
move .\tmp\drcom.vbs %filepath% > nul
rd .\tmp

rem =============log=============
echo %startmenu%\drcom.vbs.lnk > install.log
echo %filepath% >> install.log

rem =============autostart=============

cscript.exe /nologo C:\Users\%username%"\drcom_autologin\drcom.vbs

echo Successfully installed.
pause

:end
