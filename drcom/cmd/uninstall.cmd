@echo off
setlocal enabledelayedexpansion

set /p check=Remove?[y/n]:
if /i "%a%"=="n" goto :End
if /i "%a%"=="y" goto :Remove
if /i "%a%"=="N" goto :End
if /i "%a%"=="Y" goto :Remove

:Remove
del /Q "C:\Users\%username%\drcom_autologin"
rd "C:\Users\%username%\drcom_autologin"
del /Q "C:\Users\%username%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\drcom.vbs.lnk"
del .\install.log

echo ------------------------------------------------------------------------------
echo If there is nothing was printed above, the uninstallation is successful.
echo ------------------------------------------------------------------------------

:End
pause
