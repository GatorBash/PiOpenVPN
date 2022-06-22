#!/bin/bash

if [[ $EUID -ne 0 ]]
then
   echo "This script must be run as root; run \"sudo -i\" this will log you into root." 
   exit 1
fi
#update repos
apt update -y
wait
apt install openvpn -y
wait

