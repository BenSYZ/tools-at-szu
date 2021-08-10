# !/bin/sh

basedir="$(dirname $0)"

mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/.config/systemd/user"

cp "$basedir/drcom.sh" "$HOME/.local/bin/"
cp "$basedir/drcom.service" "$HOME/.config/systemd/user/"

systemctl --user enable drcom.service --now
