#!/bin/bash

USER=$USER

# install packages:
echo 'installing packages'
sleep 0.1
sudo apt update && sudo apt dist-upgrade -y && sudo apt autoremove -y && sudo apt install -y git wget curl sway waybar wtype bridge-utils foot iptables iptables-persistent wget zsh zsh-autosuggestions zsh-syntax-highlighting copyq wf-recorder

# setup config dir
echo 'creating config dir'
sleep 0.1
if [ ! -d "$HOME/.config" ]; then
    mkdir -p "$HOME/.config"
fi

# download and install dot files
echo 'downloading dot-files'
sleep 0.1
cd /tmp
git clone https://github.com/backdoorsecurity/Solitude.git && cd Solitude
cp -r host-os/dot-files/.config/* $HOME/.config
sudo cp -r host-os/dot-files/.config/* $HOME/.config
cp host-os/dot-files/.z* $HOME/
sudo cp host-os/dot-files/.zshrc /root

# allow $USER passwordless commands
echo 'set up passwordless commands'
sleep 0.1
echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$USER
sudo chmod 0440 /etc/sudoers.d/$USER

# autologin $USER
echo 'setting up autologin'
sleep 0.1
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
echo -e "[Service]\nExecStart=\nExecStart=-/sbin/agetty --autologin "$USER" --noclear %I 38400 linux" > /tmp/override.conf
sudo mv /tmp/override.conf /etc/systemd/system/getty@tty1.service.d && sudo systemctl daemon-reload

# setup systemd service files
echo 'installing system service files'
sleep 0.1
echo -e "[Unit]\nDescription=Apply system and network profiles\nAfter=sockets.target\n\n[Service]\nType=oneshot\nExecStart=/home/"$USER"/.config/sway/scripts/startup.sh\nRemainAfterExit=no\n\n[Install]\nWantedBy=sockets.target" > /tmp/startup.service
echo -e "[Unit]\nDescription=Switch cpu turbo and energy bias based on ac/battery\nAfter=sockets.target\n\n[Service]\nType=simple\nExecStart=/"$USER"/.config/sway/scripts/pwr_perf.sh\nRemainAfterExit=yes\n\n[Install]\nWantedBy=sockets.target" > /tmp/pwr_perf.service
sudo cp /tmp/*.service /etc/systemd/system/
sudo systemctl enable startup.service
sudo systemctl enable pwr_perf.service

#set shell to zsh
echo 'changing shell to zsh'
sleep 0.1
sudo chsh -s /usr/bin/zsh "$USER"
sudo chsh -s /usr/bin/zsh root
