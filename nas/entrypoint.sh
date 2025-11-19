#!/bin/sh

# IP SAN del NAS
ip addr add 10.0.30.10/24 dev eth0
ip link set eth0 up

# Gateway -> coreA
ip route add default via 10.0.30.2

echo "nas READY"
tail -f /dev/null
