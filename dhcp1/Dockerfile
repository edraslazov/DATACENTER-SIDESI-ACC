FROM ubuntu:22.04

RUN apt update && \
    apt install -y isc-dhcp-server iproute2 iputils-ping && \
    rm -rf /var/lib/apt/lists/*

RUN echo 'INTERFACESv4="eth0"' > /etc/default/isc-dhcp-server

COPY dhcpd.conf /etc/dhcp/dhcpd.conf

RUN mkdir -p /var/lib/dhcp && touch /var/lib/dhcp/dhcpd.leases

CMD ["/usr/sbin/dhcpd", "-4", "-f", "-d", "eth0"]
