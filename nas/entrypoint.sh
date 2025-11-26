#!/bin/sh

# Crear directorio compartido si no existe
mkdir -p /srv/samba/share
chmod 777 /srv/samba/share

# Configurar Samba
echo "Configurando usuario Samba..."
(echo "samba"; echo "samba") | smbpasswd -a -s root

# Iniciar Samba en primer plano con más logs
echo "Iniciando servidor Samba..."

# Iniciar Samba con más verbosidad
exec smbd -F -p 2139 -p 2445 -d=3 --no-process-group
