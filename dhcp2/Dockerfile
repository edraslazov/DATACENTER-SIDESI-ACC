FROM ubuntu:22.04

# Instalar DHCP, Zabbix Agent y utilidades
RUN apt update && \
    apt install -y isc-dhcp-server iproute2 iputils-ping zabbix-agent && \
    rm -rf /var/lib/apt/lists/*

# Interfaz donde escuchará DHCP (LAN B)
RUN echo 'INTERFACESv4="eth0"' > /etc/default/isc-dhcp-server

# Configuración de DHCP
COPY dhcpd.conf /etc/dhcp/dhcpd.conf

# Archivo de leases
RUN mkdir -p /var/lib/dhcp && touch /var/lib/dhcp/dhcpd.leases

# Configuración del Zabbix Agent para DHCP2
RUN mkdir -p /etc/zabbix/zabbix_agentd.d /var/run/zabbix /var/log/zabbix && \
    rm -f /etc/zabbix/zabbix_agentd.conf && \
    printf 'PidFile=/var/run/zabbix/zabbix_agentd.pid\n\
LogFile=/var/log/zabbix/zabbix_agentd.log\n\
Server=10.0.40.61,10.0.10.250,10.0.20.250\n\
ServerActive=10.0.40.61\n\
Hostname=dhcp2\n\
Include=/etc/zabbix/zabbix_agentd.d/*.conf\n\
AllowRoot=1\n' > /etc/zabbix/zabbix_agentd.conf

# UserParameters para métricas DHCP
RUN printf 'UserParameter=dhcp.leases.active,grep -c \"lease \" /var/lib/dhcp/dhcpd.leases\n\
UserParameter=dhcp.service.status,pgrep -x dhcpd >/dev/null && echo 1 || echo 0\n' \
    > /etc/zabbix/zabbix_agentd.d/dhcp.conf

# EntryPoint
RUN printf '#!/bin/bash\n\
set -e\n\
echo \"[ENTRYPOINT] Iniciando Zabbix Agent dhcp2...\"\n\
zabbix_agentd\n\
echo \"[ENTRYPOINT] Iniciando DHCPD en eth0 LAN_B...\"\n\
exec /usr/sbin/dhcpd -4 -f -d eth0\n' \
> /entrypoint.sh && chmod +x /entrypoint.sh

EXPOSE 67/udp

CMD ["/entrypoint.sh"]
