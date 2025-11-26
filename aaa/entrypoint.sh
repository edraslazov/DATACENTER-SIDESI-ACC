#!/bin/sh

echo "========== AAA / FreeRADIUS =========="
ip addr
echo "======================================"

# Levantar FreeRADIUS
exec /usr/sbin/freeradius -f