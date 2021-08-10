# !/bin/sh

systemctl --user disable drcom.service --now
rm "$HOME/.config/systemd/user/drcom.service"
rm "$HOME/.local/bin/drcom.sh"

rmdir -p "$HOME/.config/systemd/user" 2>/dev/null
rmdir -p "$HOME/.local/bin" 2>/dev/null
