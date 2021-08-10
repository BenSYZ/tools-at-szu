# !/bin/sh
Launchctl stop $HOME/Library/LaunchAgents/com.drcom.app.plist
Launchctl unload $HOME/Library/LaunchAgents/com.drcom.app.plist 2> /dev/null

rm $HOME/Library/LaunchAgents/com.drcom.app.plist
rm $HOME/.local/bin/drcom.sh

rmdir -p $HOME/.local/bin 2> /dev/null
rmdir -p $HOME/Library/LaunchAgent 2> /dev/null

