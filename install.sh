#!/bin/bash

USER=$USER

# install packages:
sudo apt update && sudo apt dist-upgrade -y && sudo apt autoremove -y && sudo apt install -y git wget curl sway waybar wtype bridge-utils foot iptables iptables-persistent wget zsh zsh-autosuggestions zsh-syntax-highlighting copyq wf-recorder

# setup config dir
if [ ! -d "$HOME/.config" ]; then
    mkdir -p "$HOME/.config"
fi

# download and install dot files
cd /tmp
git clone https://github.com/backdoorsecurity/Solitude.git && cd Solitude
cp -r host-os/dot-files/.config/* $HOME/.config
cp host-os/dot-files/.z* $HOME/

# allow $USER passwordless commands
echo " "$USER" ALL=(ALL) NOPASSWD: ALL" > tmp/usermods
sudo mv /tmp/usermods /etc/sudoers.d/

# autologin $USER
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
echo -e "[Service]\nExecStart=\nExecStart=-/sbin/agetty --autologin "$USER" --noclear %I 38400 linux" > /tmp/override.conf
sudo mv /tmp/override.conf /etc/systemd/system/getty@tty1.service.d && systemctl daemon-reload

# setup systemd service files
echo -e "[Unit]\nDescription=Apply system and network profiles\nAfter=sockets.target\n\n[Service]\nType=oneshot\nExecStart=/home/"$USER"/.config/sway/scripts/startup.sh\nRemainAfterExit=no\n\n[Install]\nWantedBy=sockets.target > /etc/systemd/system/startup.service
echo -e "[Unit]\nDescription=Switch cpu turbo and energy bias based on ac/battery\nAfter=sockets.target\n\n[Service]\nType=simple\nExecStart=/"$USER"/.config/sway/scripts/pwr_perf.sh\nRemainAfterExit=yes\n\n[Install]\nWantedBy=sockets.target" > /etc/systemd/system/pwr_perf.service
systemctl enable startup.service, pwr_perf.service
