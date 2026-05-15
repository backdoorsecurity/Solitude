#!/bin/bash

USER=$USER
IFACE=eth0
IP_ADDRESS=10.10.10.1/28
NETMASK=255.255.255.240
MTU=9000

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
cp -r net-vm/dot-files/.config/* $HOME/.config
sudo cp -r net-vm/dot-files/.config/* $HOME/.config
cp net-vm/dot-files/.z* $HOME/
sudo cp net-vm/dot-files/.zshrc /root

#set shell to zsh
echo 'switching to zsh'
sudo /sbin/usermod -s /usr/bin/zsh "$USER"

#allow kernel level ip forwarding
echo "enabling ip forwarding"
sleep 0.1
sudo tee /etc/sysctl.d/99-forwarding.conf > /dev/null << EOF
net.ipv4.ip_forward=1
net.ipv4.conf.all.forwarding=1
EOF

#use old network naming convention
echo "net.ifnames=0"
sleep 0.1
sudo tee /etc/kernel/cmdline > /dev/null << EOF
net.ifnames=0
EOF

sudo /sbin/update-initramfs -u -k all

#fill /etc/network/interfaces
echo "Configuring eth0 network interface"
echo "
# virtio network
auto $IFACE
iface $IFACE inet static
        address $IP_ADDRESS
        netmask $NETMASK
        MTU=$MTU
" | sudo tee -a /etc/network/interfaces > /dev/null

echo "/etc/network/interfaces configured"
