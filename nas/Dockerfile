FROM ubuntu:22.04

# Instalar dependencias
RUN apt update && \
    DEBIAN_FRONTEND=noninteractive apt install -y \
    samba \
    samba-common \
    smbclient \
    dos2unix \
    && rm -rf /var/lib/apt/lists/*

# Crear directorio para compartir
RUN mkdir -p /srv/samba/share
RUN chmod 1777 /srv/samba/share

# Copiar archivos de configuración
COPY smb.conf /etc/samba/smb.conf
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# Normalizar y asegurar permisos
RUN dos2unix /usr/local/bin/entrypoint.sh && \
    chmod +x /usr/local/bin/entrypoint.sh && \
    chmod 777 /etc/samba/smb.conf && \
    chmod -R 777 /srv/samba

EXPOSE 2139/tcp 2445/tcp
VOLUME ["/srv/samba/share"]

CMD ["/usr/local/bin/entrypoint.sh"]