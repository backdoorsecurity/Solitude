#!/bin/bash

#remove unnecessary pci devices
#echo '1' > '/sys/bus/pci/devices/0000:00:1f.0/remove'
##echo '1' > '/sys/bus/pci/devices/0000:00:1f.3/remove'
#echo '1' > '/sys/bus/pci/devices/0000:00:1f.4/remove'
#echo '1' > '/sys/bus/pci/devices/0000:00:1f.5/remove'
#echo '1' > '/sys/bus/pci/devices/0000:00:1f.6/remove'
#echo '1' > '/sys/bus/pci/devices/0000:01:00.1/remove'
#echo '1' > '/sys/bus/pci/devices/0000:01:00.0/remove'
##echo '1' > '/sys/bus/pci/devices/0000:00:1e.0/remove'
#echo '1' > '/sys/bus/pci/devices/0000:00:17.0/remove'

#unbind pci devices
#echo '0000:00:1f.3' > '/sys/bus/pci/devices/0000:00:1f.3/driver/unbind'
#echo 'vfio-pci' > '/sys/bus/pci/devices/0000:00:1f.3/driver_override'
#echo '0000:01:00.1' > '/sys/bus/pci/devices/0000:01:00.1/driver/unbind'
#echo 'vfio-pci' > '/sys/bus/pci/devices/0000:01:00.1/driver_override'
#echo '0000:01:00.0' > '/sys/bus/pci/devices/0000:01:00.0/driver/unbind'
#echo 'vfio-pci' > '/sys/bus/pci/devices/0000:01:00.0/driver_override'

#battery charge profiles
#echo '65' > '/sys/class/power_supply/BAT0/charge_control_start_threshold'
#echo '65' > '/sys/class/power_supply/BAT0/charge_control_start_threshold'
#echo '65' > '/sys/class/power_supply/BAT0/charge_control_start_threshold'
#echo '65' > '/sys/class/power_supply/BAT0/charge_start_threshold'
#echo '65' > '/sys/class/power_supply/BAT0/charge_start_threshold'
#echo '65' > '/sys/class/power_supply/BAT0/charge_start_threshold'

#echo '75' > '/sys/class/power_supply/BAT0/charge_control_end_threshold'
#echo '75' > '/sys/class/power_supply/BAT0/charge_control_end_threshold'
#echo '75' > '/sys/class/power_supply/BAT0/charge_control_end_threshold'
#echo '75' > '/sys/class/power_supply/BAT0/charge_stop_threshold'
#echo '75' > '/sys/class/power_supply/BAT0/charge_stop_threshold'
#echo '75' > '/sys/class/power_supply/BAT0/charge_stop_threshold'

#configure and start virt network
sudo ip link add name br0 type bridge
sudo ip link set dev br0 state up
sudo ip link set dev br0 up
sudo ip link set dev br0 mtu 9000
sudo ip addr add 10.10.10.0/28 dev br0
sudo ip route add default via 10.10.10.1 dev br0
virsh start net-vm
virsh start browzer
exit
