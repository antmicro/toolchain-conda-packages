#!/bin/bash

# Run this after starting the QEMU

export HOST_IFACE=enp0s31f6
export BRIDGE=br0
export TAP=tap0

if [[ $1 == "establish" ]]; then
    ip addr flush dev ${HOST_IFACE}
    ifconfig ${HOST_IFACE} down
    ifconfig ${TAP} down
    brctl addbr ${BRIDGE}
    brctl addif ${BRIDGE} ${HOST_IFACE}
    brctl addif ${BRIDGE} ${TAP}
    ifconfig ${HOST_IFACE} up
    ifconfig ${TAP} up
    ifconfig ${BRIDGE} up
    dhclient -v ${BRIDGE}
elif [[ $1 == "clear" ]]; then
    ifconfig ${BRIDGE} down
    brctl delbr br0
    dhclient
else
    echo "Invalid argument!"
    echo "Usage: ./qemu-network.sh <establish/clear>"
    echo "establish - bridge QEMU with host interface to provide internet conectivity"
    echo "clear - restore interface configuration"
    exit 1
fi

exit 0
