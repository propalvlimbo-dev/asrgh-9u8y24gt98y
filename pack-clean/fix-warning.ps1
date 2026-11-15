# fix-warning.ps1
# Ubiraet iz uzhe sozdannogo instansa "-Xms/-Xmx" v JvmArgs,
# iz-za kotoryh Prism pokazyvaet preduprezhdenie o pamyati JVM.
#
# Zapusk (zakroy Prism pered etim):
#   pravym klikom -> "Vypolnit s pomoshchyu PowerShell"
#   ili: powershell -NoProfile -ExecutionPolicy Bypass -File .\fix-warning.ps1

param(
    [string]$PrismInstances = (Join-Path $env:APPDATA 'PrismLauncher\instances'),
    [string]$InstanceName   = 'PvP Clean 1.21.11'
)

$cfg = Join-Path (Join-Path $PrismInstances $InstanceName) 'instance.cfg'
if (-not (Test-Path $cfg)) {
    Write-Host "Ne nayden: $cfg" -ForegroundColor Red
    Write-Host 'Ukazhi papku: -PrismInstances "D:\PrismLauncher\instances"' -ForegroundColor Yellow
    exit 1
}

Copy-Item $cfg ($cfg + '.bak') -Force
$text = Get-Content $cfg -Raw
$new  = $text -replace '-Xms\S+\s*', '' -replace '-Xmx\S+\s*', ''
Set-Content -Path $cfg -Value $new -Encoding ASCII

Write-Host "Gotovo. Rezervnaya kopiya: instance.cfg.bak" -ForegroundColor Green
Write-Host "Teper v Prism: instans -> Pravka -> Java -> pamyat zaday polzunkami (4 GB / 10 GB)." -ForegroundColor White
