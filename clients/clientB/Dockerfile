FROM ubuntu:22.04

RUN apt update && \
    apt install -y isc-dhcp-client iproute2 iputils-ping dnsutils freeradius-utils smbclient curl && \
    rm -rf /var/lib/apt/lists/*

CMD ["/bin/sh", "-c", "\
  dhclient eth0 || true; \
  ip route del default 2>/dev/null || true; \
  ip route add default via 10.0.20.254; \
  tail -f /dev/null"]