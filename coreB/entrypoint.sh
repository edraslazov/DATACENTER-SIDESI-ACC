#!/bin/sh

# IPs en cada interfaz
ip addr add 10.0.20.254/24 dev eth0   # LAN B
ip addr add 10.0.40.3/24  dev eth1   # Core / FW
ip addr add 10.0.30.3/24  dev eth2   # SAN

ip link set eth0 up
ip link set eth1 up
ip link set eth2 up

echo 1 > /proc/sys/net/ipv4/ip_forward

ip route del default 2>/dev/null || true

# Rutas directas a sus redes locales
ip route add 10.0.20.0/24 dev eth0
ip route add 10.0.30.0/24 dev eth2

# 🔴 Ruta hacia LAN A (10.0.10.0/24) via coreA
ip route add 10.0.10.0/24 via 10.0.40.2

# (opcional) Default hacia el firewall
ip route add default via 10.0.40.254

echo "coreB READY"
tail -f /dev/null
