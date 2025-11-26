FROM debian:stable

# Instalar CUPS y utilidades
RUN apt update && \
    apt install -y cups cups-client cups-bsd printer-driver-all && \
    apt clean

# Permitir configuración remota
RUN sed -i 's/Listen localhost:631/Port 631/g' /etc/cups/cupsd.conf && \
    sed -i 's/<Location \/>/<Location \/> \n  Allow All/g' /etc/cups/cupsd.conf && \
    sed -i 's/<Location \/admin>/<Location \/admin> \n  Allow All/g' /etc/cups/cupsd.conf

# Habilitar CUPS al iniciar
CMD ["/usr/sbin/cupsd", "-f"]

EXPOSE 631
