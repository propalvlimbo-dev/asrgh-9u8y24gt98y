# fix-deps.ps1
# Dovozit NEDOSTAYUSHCHIE biblioteki (zavisimosti) dlya modov sborki.
# Nuzhen, esli pri zapuske igra pishet "Incompatible mods found!" i trebuet
# ukulib / yet_another_config_lib_v3 / fabric-language-kotlin i t.p.
#
# Zapusk (Prism mozhno ne zakryvat, no luchshe zakryt):
#   pravym klikom -> "Vypolnit s pomoshchyu PowerShell"
#   ili: powershell -NoProfile -ExecutionPolicy Bypass -File .\fix-deps.ps1

param(
    [string]$PrismInstances = (Join-Path $env:APPDATA 'PrismLauncher\instances'),
    [string]$InstanceName   = 'PvP Clean 1.21.11',
    [string]$GameVersion    = '1.21.11'
)

$ErrorActionPreference = 'Continue'
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}
$ua = @{ 'User-Agent' = 'pvp-clean/1.0' }

$modsDir = Join-Path (Join-Path $PrismInstances $InstanceName) 'minecraft\mods'
if (-not (Test-Path $modsDir)) {
    Write-Host "NE NAYDENA papka mods: $modsDir" -ForegroundColor Red
    Write-Host 'Ukazhi papku: -PrismInstances "D:\PrismLauncher\instances"' -ForegroundColor Yellow
    exit 1
}

$gv = [uri]::EscapeDataString('["' + $GameVersion + '"]')
$ld = [uri]::EscapeDataString('["fabric"]')

function Get-BySlug([string]$slug) {
    $u = "https://api.modrinth.com/v2/project/$slug/version?game_versions=$gv&loaders=$ld&limit=1"
    $r = @(Invoke-RestMethod -Uri $u -Headers $ua -Method Get)
    if ($r.Count -eq 0) { throw "net versii pod $GameVersion" }
    return $r[0]
}
function Get-ById([string]$id) { return Invoke-RestMethod -Uri "https://api.modrinth.com/v2/version/$id" -Headers $ua -Method Get }
function Get-ByProject([string]$pid) {
    $u = "https://api.modrinth.com/v2/project/$pid/version?game_versions=$gv&loaders=$ld&limit=1"
    $r = @(Invoke-RestMethod -Uri $u -Headers $ua -Method Get)
    if ($r.Count -eq 0) { throw "net versii pod $GameVersion" }
    return $r[0]
}
function Get-File($v) {
    $f = $v.files | Where-Object { $_.primary } | Select-Object -First 1
    if (-not $f) { $f = $v.files | Select-Object -First 1 }
    if (-not $f) { throw 'u versii net faylov' }
    return $f
}

# Mod slugi sborki: po nim Modrinth sam skazhet, kakie biblioteki nuzhny
$roots = @('fabric-api','sodium','lithium','ferrite-core','modernfix','krypton','immediatelyfast',
           'entityculling','scalablelux','ixeris','tick-sync','sodium-extra','reeses-sodium-options',
           'fullscreen-tweaks','hitcolorx','betterhurtcam','bactromod','shieldscale','modmenu','zoomify')

# Strakhovka: eti biblioteki stavim vsegda, esli ih net
$knownLibs = @('ukulib','yacl','fabric-language-kotlin','architectury-api','cloth-config',
               'balm','midnightlib','fzzy-config','libjf','utilize','placeholder-api')

$queue   = New-Object System.Collections.Queue
$seen    = @{}
$added   = New-Object System.Collections.ArrayList
$errors  = New-Object System.Collections.ArrayList

foreach ($s in $roots)     { $queue.Enqueue([pscustomobject]@{ Kind = 'slug'; Value = $s }) }
foreach ($s in $knownLibs) { $queue.Enqueue([pscustomobject]@{ Kind = 'slug'; Value = $s }) }

Write-Host "Papka mods: $modsDir" -ForegroundColor Cyan
Write-Host "Ishchu i dokachivayu zavisimosti..." -ForegroundColor Cyan

$guard = 0
while ($queue.Count -gt 0) {
    $guard++
    if ($guard -gt 120) { break }
    $item = $queue.Dequeue()
    try {
        switch ($item.Kind) {
            'slug'    { $v = Get-BySlug    -slug $item.Value }
            'version' { $v = Get-ById      -id $item.Value }
            'project' { $v = Get-ByProject -pid $item.Value }
            default   { continue }
        }
        $pidKey = $v.project_id
        if ($pidKey -and $seen.ContainsKey($pidKey)) { continue }
        if ($pidKey) { $seen[$pidKey] = $true }

        $file = Get-File $v
        $dest = Join-Path $modsDir $file.filename
        if (Test-Path $dest) {
            Write-Host ("  est  {0}" -f $file.filename) -ForegroundColor DarkGray
        } else {
            Invoke-WebRequest -Uri $file.url -OutFile $dest -Headers $ua -UseBasicParsing
            Write-Host ("  +    {0} {1}" -f $item.Value, $v.version_number) -ForegroundColor Green
            [void]$added.Add(("{0} {1}" -f $item.Value, $v.version_number))
        }

        foreach ($dep in @($v.dependencies)) {
            if (-not $dep) { continue }
            if ($dep.dependency_type -ne 'required') { continue }
            if ($dep.version_id)      { $queue.Enqueue([pscustomobject]@{ Kind = 'version'; Value = $dep.version_id }) }
            elseif ($dep.project_id)  { $queue.Enqueue([pscustomobject]@{ Kind = 'project'; Value = $dep.project_id }) }
        }
    } catch {
        [void]$errors.Add(("{0}: {1}" -f $item.Value, $_.Exception.Message))
    }
}

Write-Host ''
if ($added.Count -eq 0) {
    Write-Host 'Vse zavisimosti na meste - nichego dobavlyat ne nuzhno.' -ForegroundColor Green
} else {
    Write-Host ("Dobavleno: {0}" -f $added.Count) -ForegroundColor Green
    foreach ($a in $added) { Write-Host ("  - {0}" -f $a) -ForegroundColor Green }
}
if ($errors.Count -gt 0) {
    Write-Host ("Ne udalos: {0}" -f $errors.Count) -ForegroundColor Yellow
    foreach ($e in $errors) { Write-Host ("  - {0}" -f $e) -ForegroundColor DarkYellow }
}
Write-Host ''
Write-Host 'Teper zapuskay igru. Esli opyat "Incompatible mods" - skopiruy tekst oshibki v chat.' -ForegroundColor White
