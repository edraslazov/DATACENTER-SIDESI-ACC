#!/bin/bash

echo "[INFO] Iniciando configuración del Firewall..."

# 1. ACTIVAR ENRUTAMIENTO
sysctl -w net.ipv4.ip_forward=1

# 2. RUTAS ESTÁTICAS
ip route add 10.0.10.0/24 via 10.0.40.2
ip route add 10.0.20.0/24 via 10.0.40.3
ip route add 10.0.30.0/24 via 10.0.40.2

echo "[INFO] Rutas agregadas."

# 3. LIMPIAR REGLAS
iptables -F
iptables -t nat -F
iptables -X

# 4. POLÍTICAS POR DEFECTO (Default Deny)
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

echo "[INFO] Políticas por defecto aplicadas (Default Deny)."

# 5. LOOPBACK
iptables -A INPUT -i lo -j ACCEPT

# 6. CONEXIONES ESTABLECIDAS
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

# 7. NAT
iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE

# 8. PROTECCIÓN ANTI-DDOS
iptables -A INPUT -p tcp --syn -m limit --limit 1/s --limit-burst 3 -j ACCEPT
iptables -A INPUT -p tcp --syn -j DROP

# 9. ICMP (Ping) limitado
iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 1/s -j ACCEPT
iptables -A FORWARD -p icmp -j ACCEPT

# 10. SEGMENTACIÓN DE RED
# DMZ: Solo HTTP/HTTPS desde redes internas
iptables -A FORWARD -s 10.0.10.0/24 -d 10.0.60.10 -p tcp -m multiport --dports 80,443 -j ACCEPT
iptables -A FORWARD -s 10.0.20.0/24 -d 10.0.60.10 -p tcp -m multiport --dports 80,443 -j ACCEPT

# SAN: Solo desde Cores
iptables -A FORWARD -s 10.0.40.2 -d 10.0.30.0/24 -p tcp --dport 445 -j ACCEPT
iptables -A FORWARD -s 10.0.40.3 -d 10.0.30.0/24 -p tcp --dport 445 -j ACCEPT
iptables -A FORWARD -d 10.0.30.0/24 -j DROP

# 11. SERVICIOS PERMITIDOS
# DNS
iptables -A FORWARD -d 10.0.10.20 -p udp --dport 53 -j ACCEPT
iptables -A FORWARD -d 10.0.10.20 -p tcp --dport 53 -j ACCEPT

# Zabbix
iptables -A FORWARD -s 10.0.40.61 -p tcp --dport 10050 -j ACCEPT
iptables -A FORWARD -d 10.0.40.61 -p tcp --dport 10051 -j ACCEPT

# RADIUS/AAA
iptables -A FORWARD -d 10.0.10.30 -p udp -m multiport --dports 1812,1813 -j ACCEPT

# 12. LOGGING (tráfico bloqueado)
iptables -N LOGGING
iptables -A FORWARD -j LOGGING
iptables -A LOGGING -m limit --limit 2/min -j LOG --log-prefix "FW-DROP: " --log-level 4
iptables -A LOGGING -j DROP

echo "[INFO] Reglas de IPTables aplicadas."
echo "[INFO] Firewall configurado correctamente."

# Mostrar resumen
iptables -L -n -v

# Mantener contenedor vivo
exec tail -f /dev/null