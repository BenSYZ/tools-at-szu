# !/bin/sh

mkdir -p $HOME/.local/bin
mkdir -p $HOME/.config/systemd/user

cp ./drcom.sh $HOME/.local/bin/
cp ./drcom.service $HOME/.config/systemd/user

systemctl --user enable drcom.service --now
