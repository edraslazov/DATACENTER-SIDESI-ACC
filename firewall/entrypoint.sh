#!/bin/bash

# 1. ACTIVAR ENRUTAMIENTO (IP FORWARDING)
# Sin esto, el contenedor bloquea el tráfico que no es para él mismo.
sysctl -w net.ipv4.ip_forward=1

echo "[INFO] Iniciando configuración del Firewall..."

# -------------------------------------------------------
# 2. RUTAS ESTÁTICAS (Saber dónde están las redes internas)
# -------------------------------------------------------
# El firewall está conectado a los Cores por la red 10.0.40.0/24.
# Necesita saber que detrás de esos Cores hay más redes.

# Red Access A (10.0.10.0) está detrás de Core A (10.0.40.2)
ip route add 10.0.10.0/24 via 10.0.40.2

# Red Access B (10.0.20.0) está detrás de Core B (10.0.40.3)
ip route add 10.0.20.0/24 via 10.0.40.3

# Red SAN (10.0.30.0) asumiremos que se llega por Core A (o B)
ip route add 10.0.30.0/24 via 10.0.40.2

echo "[INFO] Rutas agregadas."

# -------------------------------------------------------
# 3. CONFIGURACIÓN DE NAT Y REGLAS (IPTABLES)
# -------------------------------------------------------

# Limpiar reglas viejas
iptables -F
iptables -t nat -F

# --- NAT (Para salir a Internet/WAN) ---
# Asumiendo que eth1 es la interfaz conectada a net_wan (10.0.50.x)
# Todo lo que salga por eth1 se "enmascara" con la IP del firewall.
iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE

# --- POLITICAS DE SEGURIDAD BASICAS ---
# Aceptar todo lo que viene de adentro (eth0 - Core) hacia afuera (eth1 - WAN)
iptables -A FORWARD -i eth0 -o eth1 -j ACCEPT

# Aceptar paquetes que pertenecen a conexiones ya establecidas (respuestas de internet)
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

# (Opcional) Reglas para la DMZ
# Permitir acceso desde WAN a DMZ (Web Server 10.0.60.10) puerto 80
iptables -t nat -A PREROUTING -i eth1 -p tcp --dport 80 -j DNAT --to-destination 10.0.60.10:80
iptables -A FORWARD -i eth1 -o eth2 -p tcp --dport 80 -d 10.0.60.10 -j ACCEPT

echo "[INFO] Reglas de IPTables aplicadas."

# -------------------------------------------------------
# 4. MANTENER EL CONTENEDOR VIVO
# -------------------------------------------------------
# Esto es crucial. Si el script termina, el contenedor se apaga.
exec tail -f /dev/null