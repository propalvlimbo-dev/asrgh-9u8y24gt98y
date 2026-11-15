# fix-fabric.ps1
# Chinit oshibku "Ne udalos skachat metadannye dlya Fabric Loader":
#  1) proveryaet dostup k meta.fabricmc.net;
#  2) beret aktualnuyu stabilnuyu versiyu Fabric Loader dlya 1.21.11;
#  3) perepisyvaet komponent v mmc-pack.json instansa.
#
# Zapusk (Prism dolzhen byt ZAKRYT):
#   pravym klikom -> "Vypolnit s pomoshchyu PowerShell"
#   ili: powershell -NoProfile -ExecutionPolicy Bypass -File .\fix-fabric.ps1

param(
    [string]$PrismInstances = (Join-Path $env:APPDATA 'PrismLauncher\instances'),
    [string]$InstanceName   = 'PvP Clean 1.21.11',
    [string]$GameVersion    = '1.21.11'
)

$ErrorActionPreference = 'Continue'
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}
$ua = @{ 'User-Agent' = 'pvp-clean/1.0' }

Write-Host "1) Proveryayu meta.fabricmc.net ..." -ForegroundColor Cyan
$meta = $null
try {
    $meta = @(Invoke-RestMethod "https://meta.fabricmc.net/v2/versions/loader/$GameVersion" -Headers $ua -Method Get)
    Write-Host ("   OK, variantov loadera: {0}" -f $meta.Count) -ForegroundColor Green
} catch {
    Write-Host "   NE DOSTUP: meta.fabricmc.net ne otvechaet." -ForegroundColor Red
    Write-Host "   Prichiny: blokirovka provayderom / antivirus / firewall / net interneta." -ForegroundColor Yellow
    Write-Host "   Chto delat: otkroy v brauzere https://meta.fabricmc.net/v2/versions/loader/$GameVersion" -ForegroundColor White
    Write-Host "   Esli brauzer tozhe ne otkryvaet - nuzhen drugoy kanal svyazi (VPN), inache Prism ne postavit Fabric." -ForegroundColor White
    exit 1
}

$stable = $meta | Where-Object { $_.loader.stable -eq $true } | Select-Object -First 1
if (-not $stable) { $stable = $meta[0] }
$loaderVersion = $stable.loader.version
Write-Host ("2) Aktualnyy Fabric Loader: {0}" -f $loaderVersion) -ForegroundColor Green

$packPath = Join-Path (Join-Path $PrismInstances $InstanceName) 'mmc-pack.json'
if (-not (Test-Path $packPath)) {
    Write-Host "   NE NAYDEN: $packPath" -ForegroundColor Red
    Write-Host '   Ukazhi papku: -PrismInstances "D:\PrismLauncher\instances"' -ForegroundColor Yellow
    exit 1
}

Copy-Item $packPath ($packPath + '.bak') -Force
$pack = Get-Content $packPath -Raw | ConvertFrom-Json

$components = New-Object System.Collections.ArrayList
foreach ($c in @($pack.components)) {
    if ($c.uid -ne 'net.fabricmc.fabric-loader') { [void]$components.Add($c) }
}
$hasMc = $false
foreach ($c in $components) { if ($c.uid -eq 'net.minecraft') { $hasMc = $true } }
if (-not $hasMc) {
    [void]$components.Add([pscustomobject]@{ cachedName = 'Minecraft'; uid = 'net.minecraft'; version = $GameVersion; important = $true })
}
[void]$components.Add([pscustomobject]@{ cachedName = 'Fabric Loader'; uid = 'net.fabricmc.fabric-loader'; version = $loaderVersion })

$out = [ordered]@{ formatVersion = 1; components = @($components) }
$out | ConvertTo-Json -Depth 8 | Set-Content -Path $packPath -Encoding ASCII

Write-Host "3) mmc-pack.json obnovlen (bekap: mmc-pack.json.bak)" -ForegroundColor Green
Write-Host "   Zapuskay Prism i zhmi 'Zapustit'. Oshibki byt ne dolzhno." -ForegroundColor White
exit 0
