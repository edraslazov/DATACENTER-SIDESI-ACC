# 🚀 Guía de Instalación y Puesta en Marcha  
## 🖥️ Proyecto Datacenter – Entorno Docker

Este documento describe el proceso recomendado para clonar el repositorio, acceder al directorio del proyecto y ejecutar los servicios mediante **Docker Compose** usando **PowerShell** en Windows.

---

## 📌 Requisitos Previos

Antes de iniciar, asegúrate de tener instalado:

- **Docker Desktop**  
- **Git**  
- **PowerShell** (Windows Terminal recomendado)

Verifica que Docker funciona correctamente:

```powershell
docker --version
docker compose version
📥 1. Clonar el repositorio
powershell
Copiar código
git clone https://github.com/usuario/nombre-del-repo.git
Ingresar al directorio:

powershell
Copiar código
cd nombre-del-repo
📁 2. Verificar ubicación del archivo docker-compose.yml
Lista los archivos:

powershell
Copiar código
ls
Debe aparecer:

Copiar código
docker-compose.yml
Si no está, navega a la carpeta correcta:

powershell
Copiar código
cd ruta/de/tu/proyecto
🛠️ 3. Descargar las imágenes necesarias
powershell
Copiar código
docker-compose pull
Este comando descarga todas las imágenes definidas en el proyecto.

🚀 4. Levantar el entorno
powershell
Copiar código
docker-compose up -d
-d significa que todos los contenedores correrán en segundo plano.

✔️ 5. Verificar contenedores en ejecución
powershell
Copiar código
docker ps
También puedes verlos desde Docker Desktop.

🔄 6. Actualizar contenedores (si hubo cambios)
powershell
Copiar código
docker-compose pull
docker-compose up -d --force-recreate
Esto reconstruye los contenedores con las configuraciones nuevas.

🧹 7. Detener el laboratorio
powershell
Copiar código
docker-compose down
Eliminar redes y volúmenes:

powershell
Copiar código
docker-compose down -v
🔧 8. Reiniciar todo desde cero
powershell
Copiar código
docker-compose down
docker-compose up -d
📓 Notas importantes
Docker Desktop debe estar iniciado antes de ejecutar los comandos.

Si algo falla, consulta los logs del contenedor:

powershell
Copiar código
docker logs nombre_del_contenedor
