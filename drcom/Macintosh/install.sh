# !/bin/sh

basedir="$(dirname $0)"

mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/Library/LaunchAgents"
cp "$basedir/drcom.sh $HOME/.local/bin/"
cp "$basedir/com.drcom.app.plist $HOME/Library/LaunchAgents/"

Launchctl load "$HOME/Library/LaunchAgents/com.drcom.app.plist"
