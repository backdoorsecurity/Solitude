#!/bin/bash

#remove unnecessary pci devices
#echo '1' > '/sys/bus/pci/devices/0000:00:1f.0/remove'
#echo '1' > '/sys/bus/pci/devices/0000:00:1f.4/remove'
#echo '1' > '/sys/bus/pci/devices/0000:00:1f.5/remove'


#unbind pci devices
#echo '0000:00:1f.3' > '/sys/bus/pci/devices/0000:00:1f.3/driver/unbind'
#echo 'vfio-pci' > '/sys/bus/pci/devices/0000:00:1f.3/driver_override'
#echo '0000:01:00.1' > '/sys/bus/pci/devices/0000:01:00.1/driver/unbind'
#echo 'vfio-pci' > '/sys/bus/pci/devices/0000:01:00.1/driver_override'
#echo '0000:01:00.0' > '/sys/bus/pci/devices/0000:01:00.0/driver/unbind'
#echo 'vfio-pci' > '/sys/bus/pci/devices/0000:01:00.0/driver_override'

# battery charge profile
echo "Long_Life" > /sys/class/power_supply/BAT0/charge_types

#configure and start virt network
ip link add name br0 type bridge
ip link set dev br0 state up
ip link set dev br0 up
ip link set dev br0 mtu 9000
ip addr add 10.10.10.0/28 dev br0
ip route add default via 10.10.10.1 dev br0
#virsh start network
#virsh start browser
exit
