# DATACENTER-SIDESI-ACC
_Simulación de un entorno de centro de datos con Docker Compose_

[![Built with Docker](https://img.shields.io/badge/Built%20with-Docker-blue?style=for-the-badge&logo=docker)](https://www.docker.com/)

Repositorio para la simulación de una infraestructura de red de un centro de datos, utilizando Docker y Docker Compose para orquestar múltiples servicios y redes virtuales. Este proyecto fue desarrollado por estudiantes de Ingeniería de Sistemas Informáticos como una demostración práctica de conceptos de redes, seguridad y servicios de TI.

## 📜 Tabla de Contenidos
- [Arquitectura](#-arquitectura)
- [Características](#-características)
- [Prerrequisitos](#-prerrequisitos)
- [Cómo Empezar](#-cómo-empezar)
- [Interactuando con la Simulación](#-interactuando-con-la-simulación)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [Licencia](#-licencia)

## 🏛️ Arquitectura
El entorno está completamente containerizado usando Docker Compose y se divide en varios servicios y redes para simular una arquitectura de red realista.

### Servicios
- **`core_a` y `core_b`**: Actúan como los routers/switches principales del centro de datos, proporcionando enrutamiento entre las diferentes redes internas. La configuración dual simula un entorno de alta disponibilidad.
- **`firewall`**: Un servicio de firewall que protege la red interna y gestiona el tráfico entre la red de los cores (`net_fw_core`) y una red externa simulada (`net_wan`).
- **`dns1`**: Servidor DNS para la resolución de nombres en la red de acceso `net_access_a`.
- **`dhcp1` y `dhcp2`**: Servidores DHCP que asignan direcciones IP dinámicamente a los clientes en las redes `net_access_a` y `net_access_b`, respectivamente.
- **`nas`**: Un servicio de almacenamiento conectado en red (Network Attached Storage) que reside en su propia red de almacenamiento (`net_san`).
- **`client_a` y `client_b`**: Contenedores que simulan clientes o servidores en dos redes de acceso separadas, permitiendo probar la conectividad y los servicios de red.

### Redes Virtuales
- **`net_access_a` (10.0.10.0/24)**: Red de acceso para el Cliente A, con su propio servidor DHCP y DNS.
- **`net_access_b` (10.0.20.0/24)**: Red de acceso para el Cliente B, con su propio servidor DHCP.
- **`net_san` (10.0.30.0/24)**: Red de área de almacenamiento (Storage Area Network) donde reside el servicio NAS.
- **`net_fw_core` (10.0.40.0/24)**: Red troncal que interconecta los cores de la red con el firewall.
- **`net_wan` (10.0.50.0/24)**: Simula una red externa o WAN a la que el firewall se conecta.

## ✨ Características
- **Topología de Red Segmentada**: Múltiples subredes para simular redes de acceso, almacenamiento y zonas desmilitarizadas (DMZ).
- **Servicios de Red Esenciales**: Incluye DHCP para asignación de IPs y DNS para resolución de nombres.
- **Seguridad Perimetral**: Un firewall para controlar el tráfico entre la red interna y una red externa.
- **Alta Disponibilidad (Simulada)**: Dos cores de red para simular redundancia.
- **Almacenamiento Centralizado**: Un servicio NAS en una red de almacenamiento dedicada.

## 📋 Prerrequisitos
Para ejecutar esta simulación, necesitas tener instalados los siguientes componentes en tu sistema:
- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

## 🚀 Cómo Empezar
Sigue estos pasos para levantar el entorno del centro de datos.

1. **Clona el repositorio (si aún no lo has hecho):**
   ```sh
   git clone <URL_DEL_REPOSITORIO>
   cd DATACENTER-SIDESI-ACC
   ```

2. **Inicia todos los servicios:**
   Utiliza Docker Compose para construir las imágenes y levantar los contenedores en segundo plano.
   ```sh
   docker-compose up -d
   ```

3. **Detén la simulación:**
   Para detener y eliminar todos los contenedores y redes, ejecuta:
   ```sh
   docker-compose down
   ```

## 💻 Interactuando con la Simulación
Puedes acceder a la línea de comandos de cualquiera de los contenedores para realizar pruebas de red.

### Acceder a un Cliente
Para obtener una shell dentro del `clientA`:
```sh
docker exec -it clientA /bin/bash
```
Una vez dentro, puedes probar la conectividad:
```sh
# Verificar la IP asignada por DHCP
ip addr show

# Probar la conectividad con el core de su red
ping 10.0.10.254

# Probar la resolución DNS (si está configurado en el cliente)
nslookup google.com
```

Para acceder al `clientB`:
```sh
docker exec -it clientB /bin/bash
```

## 📁 Estructura del Proyecto
```
.
├── docker-compose.yml      # Orquesta todos los servicios y redes
├── README.md               # Este archivo
├── clients/                # Dockerfiles para los contenedores cliente
│   ├── clientA/
│   └── clientB/
├── coreA/                  # Configuración para el Core A
├── coreB/                  # Configuración para el Core B
├── dhcp1/                  # Configuración para el DHCP del segmento A
├── dhcp2/                  # Configuración para el DHCP del segmento B
├── dns1/                   # Configuración para el servidor DNS
├── firewall/               # Configuración para el Firewall
└── nas/                    # Configuración para el NAS
```

## 📄 Licencia
Este proyecto está bajo la Licencia MIT. Consulta el archivo `LICENSE` para más detalles.