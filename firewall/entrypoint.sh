#!/bin/sh

# Mostrar interfaces
echo "Interfaces del firewall:"
ip addr

# Habilitar reenvío IPv4 (router/firewall)
echo 1 > /proc/sys/net/ipv4/ip_forward

echo "firewall READY"

# Mantener el contenedor vivo
tail -f /dev/null
