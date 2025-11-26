FROM ubuntu:22.04

RUN apt update && \
    apt install -y freeradius freeradius-utils iproute2 iputils-ping dos2unix && \
    rm -rf /var/lib/apt/lists/*

COPY raddb/clients.conf /etc/freeradius/3.0/clients.conf
COPY raddb/users /etc/freeradius/3.0/mods-config/files/authorize

# Script de arranque
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN dos2unix /usr/local/bin/entrypoint.sh && \
    chmod +x /usr/local/bin/entrypoint.sh

CMD ["/usr/local/bin/entrypoint.sh"]
