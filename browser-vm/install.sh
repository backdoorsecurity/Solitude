#!/bin/bash

USER=$USER

# install packages:
echo 'installing packages'
sleep 0.1
sudo apt update && sudo apt dist-upgrade -y && sudo apt autoremove -y
sudo apt install -y git wget curl sway waybar wtype foot zsh zsh-autosuggestions zsh-syntax-highlighting qt6ct

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
cp -r browser-vm/dot-files/.config/* $HOME/.config
sudo cp -r browser-vm/dot-files/.config/* $HOME/.config
cp browser-vm/dot-files/.z* $HOME/
sudo cp browser-vm/dot-files/.zshrc /root

#set shell to zsh
echo 'switching to zsh'
sudo usermod -s /usr/bin/zsh "$USER"

#use old network naming convention
echo "net.ifnames=0"
sleep 0.1
sudo tee /etc/kernel/cmdline > /dev/null << EOF
net.ifnames=0
EOF

sudo update-initramfs -u -k all

#fill /etc/network/interfaces
echo "Configuring eth0 network interface"
echo "
# Virtual Ethernet to Host
auto eth0
iface eth0 inet static
    address 10.10.10.2/28
" | sudo tee -a /etc/network/interfaces > /dev/null

echo "/etc/network/interfaces configured"
