#!/bin/bash

# Habilitar enrutamiento (Convertirlo en Router)
echo 1 > /proc/sys/net/ipv4/ip_forward

# Eliminar la puerta de enlace por defecto que Docker pone (que suele ser la del bridge)
# para que podamos poner la nuestra (el Firewall).
ip route del default 2>/dev/null || true

# --- RUTAS ESTÁTICAS ---

# 1. ¿Cómo llegar a la LAN B (10.0.20.x)?
# Saltamos hacia la pata del Core B que está en nuestra misma red (10.0.40.3)
ip route add 10.0.20.0/24 via 10.0.40.3

# 2. Ruta por defecto (Internet/WAN)
# Todo lo que no sea LAN A o LAN B, se lo tiramos al Firewall
ip route add default via 10.0.40.254

echo "CoreA READY - Routing Table:"
ip route
# Mantener vivo
tail -f /dev/null