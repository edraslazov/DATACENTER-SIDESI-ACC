#!/bin/sh

# Poner coreA como gateway
ip route del default 2>/dev/null || true
ip route add default via 10.0.10.254

# ==================================================
# CONFIGURACIÓN DE NAMED (BIND9)
# ==================================================

cat >/etc/bind/named.conf.options <<EOF
options {
    directory "/var/cache/bind";
    recursion yes;
    allow-query { any; };
    forwarders { 8.8.8.8; 1.1.1.1; };
    dnssec-validation no;
    listen-on { any; };
    listen-on-v6 { none; };
};
EOF

# ==================================================
# ZONAS LOCALES (Dominios Internos)
# ==================================================

cat >/etc/bind/named.conf.local <<EOF
// Zona para el dominio interno datacenter.local
zone "datacenter.local" {
    type master;
    file "/etc/bind/db.datacenter.local";
};

// Zona de resolución inversa para 10.0.10.x (Access A)
zone "10.10.0.in-addr.arpa" {
    type master;
    file "/etc/bind/db.10.0.10";
};

// Zona de resolución inversa para 10.0.20.x (Access B)
zone "20.10.0.in-addr.arpa" {
    type master;
    file "/etc/bind/db.10.0.20";
};

// Zona de resolución inversa para 10.0.30.x (SAN)
zone "30.10.0.in-addr.arpa" {
    type master;
    file "/etc/bind/db.10.0.30";
};

// Zona de resolución inversa para 10.0.60.x (DMZ)
zone "60.10.0.in-addr.arpa" {
    type master;
    file "/etc/bind/db.10.0.60";
};
EOF

# ==================================================
# ARCHIVO DE ZONA: datacenter.local (Forward Zone)
# ==================================================

cat >/etc/bind/db.datacenter.local <<EOF
\$TTL    604800
@       IN      SOA     dns1.datacenter.local. admin.datacenter.local. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
; Servidores de nombres
@       IN      NS      dns1.datacenter.local.

; Servidor DNS
dns1            IN      A       10.0.10.20

; === CORES ===
coreA           IN      A       10.0.10.254
coreA-fw        IN      A       10.0.40.2
coreA-san       IN      A       10.0.30.2
coreB           IN      A       10.0.20.254
coreB-fw        IN      A       10.0.40.3
coreB-san       IN      A       10.0.30.3

; === FIREWALL ===
firewall        IN      A       10.0.40.254
firewall-wan    IN      A       10.0.50.2
firewall-dmz    IN      A       10.0.60.254
fw              IN      CNAME   firewall

; === SERVIDORES DHCP ===
dhcp1           IN      A       10.0.10.10
dhcp2           IN      A       10.0.20.10

; === AAA (RADIUS) ===
aaa             IN      A       10.0.10.30
radius          IN      CNAME   aaa

; === ALMACENAMIENTO ===
nas             IN      A       10.0.30.10
samba           IN      A       10.0.30.50
storage         IN      CNAME   nas

; === ZABBIX (MONITOREO) ===
zabbix-mysql    IN      A       10.0.40.60
zabbix-server   IN      A       10.0.40.61
zabbix-web      IN      A       10.0.40.62
zabbix          IN      CNAME   zabbix-web
monitor         IN      CNAME   zabbix-web

; === DMZ ===
web-dmz         IN      A       10.0.60.10
www             IN      CNAME   web-dmz

; === SERVIDOR DE IMPRESIÓN ===
printserver     IN      A       10.0.10.40
print           IN      CNAME   printserver

; === CLIENTES ===
clientA         IN      A       10.0.10.100
clientB         IN      A       10.0.20.100
EOF

# ==================================================
# ZONA INVERSA: 10.0.10.x (Access A)
# ==================================================

cat >/etc/bind/db.10.0.10 <<EOF
\$TTL    604800
@       IN      SOA     dns1.datacenter.local. admin.datacenter.local. (
                              1         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      dns1.datacenter.local.

; PTR Records (IP → Nombre)
10      IN      PTR     dhcp1.datacenter.local.
20      IN      PTR     dns1.datacenter.local.
30      IN      PTR     aaa.datacenter.local.
40      IN      PTR     printserver.datacenter.local.
51      IN      PTR     zabbix-web.datacenter.local.
100     IN      PTR     clientA.datacenter.local.
250     IN      PTR     zabbix-server.datacenter.local.
254     IN      PTR     coreA.datacenter.local.
EOF

# ==================================================
# ZONA INVERSA: 10.0.20.x (Access B)
# ==================================================

cat >/etc/bind/db.10.0.20 <<EOF
\$TTL    604800
@       IN      SOA     dns1.datacenter.local. admin.datacenter.local. (
                              1         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      dns1.datacenter.local.

; PTR Records
10      IN      PTR     dhcp2.datacenter.local.
100     IN      PTR     clientB.datacenter.local.
250     IN      PTR     zabbix-server.datacenter.local.
254     IN      PTR     coreB.datacenter.local.
EOF

# ==================================================
# ZONA INVERSA: 10.0.30.x (SAN)
# ==================================================

cat >/etc/bind/db.10.0.30 <<EOF
\$TTL    604800
@       IN      SOA     dns1.datacenter.local. admin.datacenter.local. (
                              1         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      dns1.datacenter.local.

; PTR Records
2       IN      PTR     coreA-san.datacenter.local.
3       IN      PTR     coreB-san.datacenter.local.
10      IN      PTR     nas.datacenter.local.
50      IN      PTR     samba.datacenter.local.
EOF

# ==================================================
# ZONA INVERSA: 10.0.60.x (DMZ)
# ==================================================

cat >/etc/bind/db.10.0.60 <<EOF
\$TTL    604800
@       IN      SOA     dns1.datacenter.local. admin.datacenter.local. (
                              1         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      dns1.datacenter.local.

; PTR Records
10      IN      PTR     web-dmz.datacenter.local.
254     IN      PTR     firewall-dmz.datacenter.local.
EOF

echo "[INFO] DNS1 configurado con zonas locales para datacenter.local"
echo "[INFO] Iniciando BIND9..."
/usr/sbin/named -g -u bind