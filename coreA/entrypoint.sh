#!/bin/sh

# interfaces de coreA
ip addr add 10.0.10.254/24 dev eth0
ip addr add 10.0.40.2/24  dev eth1
ip addr add 10.0.30.2/24  dev eth2

ip link set eth0 up
ip link set eth1 up
ip link set eth2 up

# Habilitar reenvío IPv4
echo 1 > /proc/sys/net/ipv4/ip_forward

echo "coreA READY"

# Mantener el contenedor vivo
tail -f /dev/null
