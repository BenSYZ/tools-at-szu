# !/bin/sh

systemctl --user disable drcom.service --now
rm $HOME/.config/systemd/user/drcom.service
rmdir -p $HOME/.local/bin
rmdir -p $HOME/.config/systemd/user
