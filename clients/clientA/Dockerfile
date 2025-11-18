FROM ubuntu:22.04

RUN apt update && \
    apt install -y isc-dhcp-client iproute2 iputils-ping && \
    rm -rf /var/lib/apt/lists/*

CMD ["/bin/sh", "-c", "dhclient eth0 && tail -f /dev/null"]