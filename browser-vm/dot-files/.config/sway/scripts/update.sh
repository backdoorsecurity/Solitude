#!/bin/bash

for IP in 10.10.10.{0..8}; do
    ssh -o ConnectTimeout=1 -o BatchMode=yes root@"$IP" "apt update -qq && apt full-upgrade -y -qq && apt autoremove -y -qq"
done
