# ./firewall/Dockerfile
FROM ubuntu:22.04

# Evitamos preguntas interactivas durante la instalación
ARG DEBIAN_FRONTEND=noninteractive

# Instalamos lo necesario.
# Quitamos iptables-persistent porque aplicaremos las reglas via script.
RUN apt-get update && \
    apt-get install -y \
    iproute2 \
    iputils-ping \
    iptables \
    dos2unix \
    bash \
    nano \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# Corregimos saltos de línea (CRLF -> LF) y damos permisos
RUN dos2unix /usr/local/bin/entrypoint.sh && \
    chmod +x /usr/local/bin/entrypoint.sh

# Usamos ENTRYPOINT para asegurar que el script corra sí o sí
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]