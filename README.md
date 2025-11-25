# DATACENTER-SIDESI-ACC
_Simulación completa de un entorno de centro de datos empresarial con Docker Compose_

[![Built with Docker](https://img.shields.io/badge/Built%20with-Docker-blue?style=for-the-badge&logo=docker)](https://www.docker.com/)
[![Linux](https://img.shields.io/badge/Firewall-iptables-FCC624?style=for-the-badge&logo=linux&logoColor=black)](https://netfilter.org/)
[![Zabbix](https://img.shields.io/badge/Monitoring-Zabbix-D40000?style=for-the-badge&logo=zabbix)](https://www.zabbix.com/)

Repositorio para la simulación de una infraestructura de red completa de un centro de datos empresarial, utilizando Docker y Docker Compose para orquestar múltiples servicios, monitoreo, seguridad y redes virtuales. Este proyecto fue desarrollado por estudiantes de Ingeniería de Sistemas Informáticos como una demostración práctica de conceptos de redes, seguridad, servicios de TI y administración de infraestructura.

## 📜 Tabla de Contenidos
- [Arquitectura](#%EF%B8%8F-arquitectura)
- [Características](#-características)
- [Prerrequisitos](#-prerrequisitos)
- [Cómo Empezar](#-cómo-empezar)
- [Acceso a Servicios](#-acceso-a-servicios)
- [Interactuando con la Simulación](#-interactuando-con-la-simulación)
- [Configuración del Firewall iptables](#%EF%B8%8F-configuración-del-firewall-iptables)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [Personalización](#-personalización)
- [Monitoreo y Troubleshooting](#-monitoreo-y-troubleshooting)
- [Licencia](#-licencia)

## 🏛️ Arquitectura
El entorno está completamente containerizado usando Docker Compose y se divide en varios servicios y redes para simular una arquitectura de red empresarial realista con alta disponibilidad, seguridad perimetral, monitoreo centralizado y servicios de autenticación.

### Servicios Principales

#### Núcleo de Red
- **`core_a` y `core_b`**: Switches/routers principales del centro de datos que proporcionan enrutamiento entre las diferentes redes internas. La configuración dual simula un entorno de alta disponibilidad con redundancia.
  - **Core A**: 10.0.10.254 (Access A), 10.0.40.2 (FW-Core), 10.0.30.2 (SAN)
  - **Core B**: 10.0.20.254 (Access B), 10.0.40.3 (FW-Core), 10.0.30.3 (SAN)

#### Seguridad
- **`firewall`**: Firewall Linux basado en **iptables** (Ubuntu 22.04) que protege la red interna, gestiona políticas de acceso, NAT y enrutamiento entre todas las redes del datacenter mediante reglas iptables personalizadas.
  - **Base**: Ubuntu 22.04 con iptables, iproute2, iputils
  - **Administración**: SSH y acceso directo al contenedor
  - **IPs**: 10.0.40.254 (FW-Core), 10.0.50.2 (WAN), 10.0.60.254 (DMZ)

#### Servicios de Red
- **`dns1`**: Servidor DNS (10.0.10.20) para resolución de nombres en la red de acceso A.
- **`dhcp1` y `dhcp2`**: Servidores DHCP que asignan direcciones IP dinámicamente:
  - **DHCP1**: 10.0.10.10 (red Access A)
  - **DHCP2**: 10.0.20.10 (red Access B)

#### Autenticación y Seguridad
- **`aaa`**: Servidor AAA (Authentication, Authorization, Accounting) en 10.0.10.30 para gestión centralizada de autenticación mediante RADIUS/TACACS+.

#### Almacenamiento
- **`nas`**: Network Attached Storage en la red SAN (10.0.30.10).
- **`samba`**: Servidor de archivos Samba/CIFS (10.0.30.50) con usuarios configurados:
  - **Usuario**: `usuario1`, **Contraseña**: `password1`
  - **Usuario**: `usuario2`, **Contraseña**: `password2`
  - **Compartido**: `Privado` en `/shared`

#### Monitoreo (Stack Zabbix)
- **`zabbix-mysql`**: Base de datos MySQL 8.0 para Zabbix (10.0.40.60)
  - **Database**: `zabbix`
  - **User**: `zabbix`
  - **Password**: `zabbix`
  - **Root Password**: `rootpass`
- **`zabbix-server`**: Motor de monitoreo Zabbix con presencia en múltiples redes:
  - 10.0.40.61 (FW-Core)
  - 10.0.10.250 (Access A)
  - 10.0.20.250 (Access B)
- **`zabbix-frontend`**: Interfaz web de Zabbix en http://localhost:8081
  - **Usuario**: `Admin`
  - **Contraseña**: `zabbix`
  - **IPs**: 10.0.10.51 (Access A), 10.0.40.62 (FW-Core)

#### DMZ y Servicios Web
- **`web_dmz`**: Servidor web NGINX en zona desmilitarizada (10.0.60.10)
  - **Puerto externo**: http://localhost:8080

#### Servicios de Impresión
- **`printserver`**: Servidor de impresión CUPS con interfaz web en http://localhost:631
  - Red: Access A
  - Volúmenes persistentes para configuración y cola de impresión

#### Clientes
- **`client_a` y `client_b`**: Contenedores que simulan estaciones de trabajo en dos redes de acceso separadas, permitiendo probar conectividad, servicios DHCP, DNS y políticas de firewall.

### Redes Virtuales
- **`net_access_a` (10.0.10.0/24)**: Red de acceso para usuarios/servicios del segmento A (DHCP, DNS, AAA, Zabbix Frontend, Print Server).
- **`net_access_b` (10.0.20.0/24)**: Red de acceso para usuarios del segmento B (DHCP).
- **`net_san` (10.0.30.0/24)**: Red de área de almacenamiento (Storage Area Network) donde residen NAS y Samba.
- **`net_fw_core` (10.0.40.0/24)**: Red troncal que interconecta los cores, firewall, Zabbix y servicios críticos.
- **`net_wan` (10.0.50.0/24)**: Simula una red externa o WAN para salida a Internet.
- **`net_dmz` (10.0.60.0/24)**: Zona desmilitarizada para servicios públicos (web_dmz).

## ✨ Características
- **Topología de Red Empresarial**: Múltiples subredes segmentadas (Access, Core, SAN, DMZ, WAN).
- **Firewall iptables**: Gestión avanzada de políticas, NAT, zonas de seguridad y routing mediante iptables en Linux.
- **Monitoreo Centralizado**: Stack completo de Zabbix para supervisión de infraestructura en tiempo real.
- **Servicios de Red Esenciales**: DHCP, DNS, AAA (RADIUS), impresión centralizada (CUPS).
- **Almacenamiento Compartido**: NAS y Samba/CIFS con control de acceso por usuario.
- **Alta Disponibilidad Simulada**: Dual-core networking para redundancia.
- **Zona Desmilitarizada (DMZ)**: Servidor web aislado con políticas restrictivas.
- **Autenticación Centralizada**: Servidor AAA para autenticación, autorización y auditoría.
- **Configuración Flexible**: Scripts de entrypoint personalizables para cada servicio.

## 📋 Prerrequisitos
Para ejecutar esta simulación, necesitas tener instalados:
- [Docker](https://docs.docker.com/get-docker/) (versión 20.10 o superior)
- [Docker Compose](https://docs.docker.com/compose/install/) (versión 2.0 o superior)
- 8 GB RAM mínimo (recomendado 16 GB para todos los servicios)
- Sistema operativo: Linux, macOS o Windows con WSL2

## 🚀 Cómo Empezar

### 1. Clona el repositorio
```sh
git clone <URL_DEL_REPOSITORIO>
cd DATACENTER-SIDESI-ACC
```

### 2. Crea los directorios de datos persistentes (si no existen)
```sh
# Windows (PowerShell)
New-Item -ItemType Directory -Force -Path "C:\samba\privado"

# Linux/macOS
mkdir -p ./samba/privado
```

### 3. Inicia todos los servicios
```sh
docker-compose up -d
```

Esto construirá todas las imágenes necesarias y levantará los contenedores en segundo plano. La primera ejecución puede tardar varios minutos.

### 4. Verifica el estado de los contenedores
```sh
docker-compose ps
```

### 5. Detén la simulación
Para detener y eliminar todos los contenedores (los datos persistentes se conservan):
```sh
docker-compose down
```

Para eliminar también volúmenes (bases de datos, configuraciones):
```sh
docker-compose down -v
```

## 🌐 Acceso a Servicios

### Zabbix (Monitoreo)
- **URL**: http://localhost:8081
- **Usuario**: `Admin`
- **Contraseña**: `zabbix`
- **Descripción**: Plataforma de monitoreo para supervisar todos los servicios del datacenter

### Firewall iptables
- **Acceso SSH**: `docker exec -it firewall /bin/bash`
- **Descripción**: Firewall Linux con iptables para gestión de políticas de red

### Servidor Web DMZ
- **URL**: http://localhost:8080
- **Descripción**: Servidor NGINX en zona desmilitarizada

### Servidor de Impresión CUPS
- **URL**: http://localhost:631
- **Descripción**: Interfaz web de administración CUPS

### Samba (Archivos Compartidos)
- **Ruta SMB**: 
  - Windows: `\\10.0.30.50\Privado`
  - Linux/Mac: `smb://10.0.30.50/Privado`
- **Credenciales**:
  - Usuario1: `usuario1` / `password1`
  - Usuario2: `usuario2` / `password2`

## 💻 Interactuando con la Simulación

### Acceder a los Clientes
```sh
# Cliente A (red Access A)
docker exec -it clientA /bin/bash

# Cliente B (red Access B)
docker exec -it clientB /bin/bash
```

### Pruebas de Conectividad desde un Cliente
```sh
# Verificar IP asignada por DHCP
ip addr show

# Probar conectividad con el core
ping 10.0.10.254

# Probar DNS
nslookup google.com 10.0.10.20

# Probar acceso al servidor web DMZ
curl http://10.0.60.10

# Verificar ruta hacia otros segmentos
traceroute 10.0.20.10
```

### Acceder al Firewall
```sh
docker exec -it firewall /bin/bash
```

Dentro del contenedor firewall:
```sh
# Ver interfaces de red
ip addr show

# Ver reglas de firewall
iptables -L -n -v

# Ver tabla NAT
iptables -t nat -L -n -v

# Ver tabla de enrutamiento
ip route show

# Activar IP forwarding (si no está activado)
sysctl -w net.ipv4.ip_forward=1

# Ver estadísticas de conexiones
conntrack -L
```

### Acceder a Zabbix Server
```sh
docker exec -it zabbix-server /bin/sh
```

### Ver logs de servicios
```sh
# Ver logs de un servicio específico
docker-compose logs -f firewall
docker-compose logs -f zabbix-server
docker-compose logs -f dhcp1

# Ver logs de todos los servicios
docker-compose logs -f
```

## 🛡️ Configuración del Firewall iptables

El firewall se configura automáticamente mediante el script `entrypoint.sh` que se ejecuta al iniciar el contenedor. Este script:

1. **Activa IP forwarding** para permitir el enrutamiento entre redes
2. **Configura rutas estáticas** hacia las redes internas a través de los cores
3. **Aplica reglas iptables** para NAT, filtrado y políticas de seguridad

### Estructura del entrypoint.sh
```bash
#!/bin/bash
# 1. Activar IP forwarding
sysctl -w net.ipv4.ip_forward=1

# 2. Configurar rutas estáticas
ip route add 10.0.10.0/24 via 10.0.40.2  # Access A via Core A
ip route add 10.0.20.0/24 via 10.0.40.3  # Access B via Core B
ip route add 10.0.30.0/24 via 10.0.40.2  # SAN via Core A

# 3. Aplicar reglas iptables (NAT, filtrado, políticas)
# ... (ver archivo completo en firewall/entrypoint.sh)
```

### Verificar configuración del firewall
```sh
# Acceder al contenedor
docker exec -it firewall /bin/bash

# Ver todas las cadenas y reglas
iptables -L -n -v

# Ver reglas de NAT
iptables -t nat -L -n -v

# Ver rutas configuradas
ip route show

# Ver estadísticas de paquetes por regla
iptables -L -n -v --line-numbers
```

### Modificar reglas del firewall
Para modificar las reglas del firewall:

1. Edita el archivo `firewall/entrypoint.sh`
2. Reconstruye y reinicia el contenedor:
```sh
docker-compose up -d --build firewall
```

### Ejemplo de reglas comunes

#### Permitir HTTP/HTTPS desde Access A hacia DMZ
```bash
iptables -A FORWARD -s 10.0.10.0/24 -d 10.0.60.10 -p tcp -m multiport --dports 80,443 -j ACCEPT
```

#### Bloquear tráfico de Access B hacia SAN
```bash
iptables -A FORWARD -s 10.0.20.0/24 -d 10.0.30.0/24 -j DROP
```

#### NAT para salida a WAN
```bash
iptables -t nat -A POSTROUTING -s 10.0.10.0/24 -o eth1 -j MASQUERADE
```

## 📁 Estructura del Proyecto
```
.
├── docker-compose.yml      # Orquesta todos los servicios y redes
├── README.md               # Este archivo
├── clients/                # Dockerfiles para los contenedores cliente
│   ├── clientA/
│   │   ├── Dockerfile
│   │   └── entrypoint.sh
│   └── clientB/
│       ├── Dockerfile
│       └── entrypoint.sh
├── coreA/                  # Configuración para el Core A
│   ├── Dockerfile
│   └── entrypoint.sh
├── coreB/                  # Configuración para el Core B
│   ├── Dockerfile
│   └── entrypoint.sh
├── dhcp1/                  # Servidor DHCP para segmento A
│   ├── Dockerfile
│   ├── dhcpd.conf
│   └── entrypoint.sh
├── dhcp2/                  # Servidor DHCP para segmento B
│   ├── Dockerfile
│   ├── dhcpd.conf
│   └── entrypoint.sh
├── dns1/                   # Servidor DNS
│   ├── Dockerfile
│   └── named.conf
├── aaa/                    # Servidor AAA (RADIUS/TACACS+)
│   ├── Dockerfile
│   └── radiusd.conf
├── firewall/               # Firewall con iptables
│   ├── Dockerfile          # Ubuntu 22.04 + iptables
│   └── entrypoint.sh       # Script de configuración de reglas
├── nas/                    # Network Attached Storage
│   └── Dockerfile
├── printserver/            # Servidor de impresión CUPS
│   └── Dockerfile
└── samba/                  # Configuración Samba
    └── privado/            # Directorio compartido
```

## 🔧 Personalización

### Agregar más clientes
Puedes clonar la configuración de `clientA` o `clientB` y añadir nuevos servicios en el `docker-compose.yml`.

### Modificar rangos DHCP
Edita los archivos `dhcp1/dhcpd.conf` y `dhcp2/dhcpd.conf` según tus necesidades.

### Cambiar credenciales
- **Zabbix**: Cambiar desde la interfaz web después del primer login
- **Samba**: Modificar el `command` del servicio en `docker-compose.yml`
- **MySQL/Zabbix**: Modificar variables de entorno en `docker-compose.yml`

### Agregar impresoras en CUPS
1. Accede a http://localhost:631
2. Ve a "Administration" → "Add Printer"
3. Sigue el wizard de configuración

### Personalizar reglas de firewall
1. Edita `firewall/entrypoint.sh`
2. Añade tus reglas iptables personalizadas
3. Reconstruye: `docker-compose up -d --build firewall`

## 📊 Monitoreo y Troubleshooting

### Verificar conectividad entre redes
```sh
# Desde clientA probar acceso a DMZ
docker exec -it clientA ping 10.0.60.10

# Verificar NAT desde firewall
docker exec -it firewall iptables -t nat -L -n -v
```

### Revisar logs de Zabbix
```sh
docker-compose logs zabbix-server
docker-compose logs zabbix-frontend
```

### Verificar reglas de firewall activas
```sh
# Ver todas las reglas en formato detallado
docker exec -it firewall iptables -L -n -v

# Ver contadores de paquetes
docker exec -it firewall iptables -L -n -v --line-numbers

# Ver reglas de NAT
docker exec -it firewall iptables -t nat -L -n -v
```

### Diagnosticar problemas de red
```sh
# Ver tabla de enrutamiento en cualquier contenedor
docker exec -it coreA ip route

# Verificar conectividad entre cores
docker exec -it coreA ping 10.0.40.3

# Traceroute desde cliente a DMZ
docker exec -it clientA traceroute 10.0.60.10

# Ver IP forwarding activo
docker exec -it firewall sysctl net.ipv4.ip_forward
```

### Capturar tráfico (debugging avanzado)
```sh
# Instalar tcpdump en el contenedor
docker exec -it firewall apt-get update && apt-get install -y tcpdump

# Capturar tráfico en una interfaz específica
docker exec -it firewall tcpdump -i eth0 -n
```

## 📄 Licencia
Este proyecto está bajo la Licencia MIT. Consulta el archivo `LICENSE` para más detalles.

---

**Desarrollado por estudiantes de Ingeniería de Sistemas Informáticos**  
*Proyecto académico - Arquitectura de Centros de Datos y Redes Empresariales*