#!/bin/bash

USER=$USER

# install packages:
echo 'installing packages'
sleep 0.1
sudo apt update && sudo apt dist-upgrade -y && sudo apt autoremove -y
sudo apt install -y wget curl sway waybar wtype foot zsh zsh-autosuggestions zsh-syntax-highlighting

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
cp -r net-vm/dot-files/.config/* $HOME/.config
sudo cp -r host-os/dot-files/.config/* $HOME/.config
cp net-vm/dot-files/.z* $HOME/
sudo cp net-vm/dot-files/.zshrc /root

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
sudo cp /tmp/*.service /etc/systemd/system/
sudo systemctl enable startup.service

#set shell to zsh
echo 'switching to zsh'
sudo usermod -s /usr/bin/zsh "$USER"

#use generic iface names like eth0, wlan0
sudo echo -e "net.ifnames=0" > /etc/kernel/cmdline
update-initramfs -u -k all

#fill in /etc/network/interfaces
echo "
# virtio net
auto eth0
iface eth0 inet static
    address 10.10.10.2/28
" | sudo tee -a /etc/network/interfaces > /dev/null
