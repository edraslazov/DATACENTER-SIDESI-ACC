#!/bin/sh

# IPs en cada interfaz
ip addr add 10.0.10.254/24 dev eth0   # LAN A
ip addr add 10.0.40.2/24  dev eth1   # Core / FW
ip addr add 10.0.30.2/24  dev eth2   # SAN

ip link set eth0 up
ip link set eth1 up
ip link set eth2 up

# Habilitar enrutamiento
echo 1 > /proc/sys/net/ipv4/ip_forward

# Limpiar default que ponga Docker
ip route del default 2>/dev/null || true

# Rutas directas a sus redes locales
ip route add 10.0.10.0/24 dev eth0
ip route add 10.0.30.0/24 dev eth2

# 🔴 Ruta hacia LAN B (10.0.20.0/24) via coreB en la red de core
ip route add 10.0.20.0/24 via 10.0.40.3

# (opcional) Default hacia el firewall
ip route add default via 10.0.40.254

echo "coreA READY"
tail -f /dev/null
