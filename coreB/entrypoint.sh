#!/bin/bash

# Habilitar enrutamiento
echo 1 > /proc/sys/net/ipv4/ip_forward

# Eliminar gateway por defecto de Docker
ip route del default 2>/dev/null || true

# --- RUTAS ESTÁTICAS ---

# 1. ¿Cómo llegar a la LAN A (10.0.10.x)?
# Saltamos hacia la pata del Core A (10.0.40.2)
ip route add 10.0.10.0/24 via 10.0.40.2

# 2. Ruta por defecto (Internet/WAN)
# Al Firewall
ip route add default via 10.0.40.254

echo "CoreB READY - Routing Table:"
ip route
# Mantener vivo
tail -f /dev/null