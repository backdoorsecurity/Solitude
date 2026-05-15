#!/bin/bash

USER=$USER
IFACE=eth0
IP_ADDRESS=10.10.10.2/28
NETMASK=255.255.255.240
IP_ROUTE=10.10.10.1
NAMESERVER=1.1.1.1
MTU=9000

# install packages:
echo 'installing packages'
sleep 0.1
sudo apt update && sudo apt dist-upgrade -y && sudo apt autoremove -y
sudo apt install -y git wget curl sway waybar waypipe wtype foot zsh zsh-autosuggestions zsh-syntax-highlighting qt6ct

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
sudo /sbin/usermod -s /usr/bin/zsh "$USER"

#add user to necessary groups
sudo /sbin/usermod -aG audio video render "$USER"

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
	gateway $IP_ROUTE
	dns-nameservers $NAMESERVER
	MTU=$MTU
" | sudo tee -a /etc/network/interfaces > /dev/null

echo "/etc/network/interfaces configured"
echo "install your web browser of choice and add name to BROWSER variable in host-operating-system/$HOME/.config/sway/keybindings/browser.kb"
