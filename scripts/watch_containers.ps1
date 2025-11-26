Param(
    [Parameter(Mandatory = $true)]
    [string]$Service
)

# Ruta de tu proyecto
$projectDir = "C:\Users\cheyo\OneDrive\Documentos\ues\admin centros de computo\DATACENTER-SIDESI-ACC"

# Archivo de log
$logFile = "C:\Users\cheyo\zbx_autorecover.log"

Set-Location $projectDir

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
"$timestamp -> Recreando servicio: $Service" | Out-File -FilePath $logFile -Append

docker compose up -d $Service
