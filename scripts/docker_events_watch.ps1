$projectDir = "C:\Users\cheyo\OneDrive\Documentos\ues\admin centros de computo\DATACENTER-SIDESI-ACC"
$logFile    = "C:\Users\cheyo\zbx_autowatch.log"

Set-Location $projectDir

Write-Host "🛰  Monitor de contenedores iniciado..."
Write-Host "Se recrearán solo los contenedores críticos cuando se destruyan.`n"

docker events --filter "type=container" --filter "event=destroy" --format "{{.Actor.Attributes.name}}" |
    ForEach-Object {
        $cname = $_.Trim()
        if (-not $cname) { return }

        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        "$timestamp -> Se destruyó el contenedor: $cname" | Out-File -FilePath $logFile -Append

        switch ($cname) {
            "coreA" { & powershell -File ".\scripts\watch_containers.ps1" coreA }
            "coreB" { & powershell -File ".\scripts\watch_containers.ps1" coreB }
            "dhcp1" { & powershell -File ".\scripts\watch_containers.ps1" dhcp1 }
            "dhcp2" { & powershell -File ".\scripts\watch_containers.ps1" dhcp2 }
            "dns1"  { & powershell -File ".\scripts\watch_containers.ps1" dns1 }
            "aaa"   { & powershell -File ".\scripts\watch_containers.ps1" aaa }
            "nas"   { & powershell -File ".\scripts\watch_containers.ps1" nas }
            "zabbix-mysql"    { & powershell -File ".\scripts\watch_containers.ps1" "zabbix-mysql" }
            "zabbix-server"   { & powershell -File ".\scripts\watch_containers.ps1" "zabbix-server" }
            "zabbix-frontend" { & powershell -File ".\scripts\watch_containers.ps1" "zabbix-frontend" }
            default {
                "$timestamp -> Contenedor no crítico: $cname (no se recrea)" | Out-File -FilePath $logFile -Append
            }
        }
    }
