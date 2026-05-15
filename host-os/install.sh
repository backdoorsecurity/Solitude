#!/bin/bash

USER=$USER
IFACE=br0
IP_ADDRESS=10.10.10.0/28
NETMASK=255.255.255.240
IP_ROUTE=10.10.10.1
NAMESERVER=1.1.1.1
MTU=9000

# install packages:
echo 'installing packages'
sleep 0.1
sudo apt update && sudo apt dist-upgrade -y && sudo apt autoremove -y
sudo apt install -y linux-headers-$(uname -r) virt-manager git wget curl sway waybar wtype bridge-utils foot wget zsh zsh-autosuggestions zsh-syntax-highlighting copyq wf-recorder oxygencursors qt6ct waypipe lm-sensors

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
#sudo systemctl enable startup.service
sudo systemctl enable pwr_perf.service

#set shell to zsh
echo 'switching shell to zsh'
sleep 0.1
sudo /sbin/usermod -s /usr/bin/zsh "$USER"
#add user to necessary groups
sudo /sbin/usermod -aG libvirt-qemu libvirt video render "$USER"

#set kernel parameters
#replace vfio-pci.ids with the pci bus id of any physical devices you intend to pass through to a guest.
#i use wireless and ethernet nic, nvidia gpu/hd audio card.
#check with lspci -nnk.
echo -n "net.ifnames=0 pcie_aspm=force memtest=0 tsx=on i915.enable_fbc=1 i915.enable_psr=1 i915.enable_dc=2 ipv6.disable=1 intel_iommu=on iommu=pt vfio-pci.ids=10de:28e0,10de:22be,10ec:8168,17aa:3842" | tee -a /etc/kernel/cmdline
/sbin/update-initramfs -u -k all

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

# can not install iptables in script due to interactive prompt not working in shell
echo "install iptables and iptables-persistent after script is finished"
