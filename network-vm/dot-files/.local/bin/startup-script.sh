#!/bin/bash
ip addr add 10.10.10.1/28 dev enp7s0
ip link set dev enp7s0 up
/root/.config/bin/scripts/INTERNET.sh
