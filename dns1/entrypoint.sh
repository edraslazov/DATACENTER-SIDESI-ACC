#!/bin/sh

# Poner coreA como gateway
ip route del default 2>/dev/null || true
ip route add default via 10.0.10.254

cat >/etc/bind/named.conf.options <<EOF
options {
    directory "/var/cache/bind";
    recursion yes;
    allow-query { any; };
    forwarders { 8.8.8.8; 1.1.1.1; };
    dnssec-validation no;
};
EOF

echo "dns1 READY"
/usr/sbin/named -g -u bind
