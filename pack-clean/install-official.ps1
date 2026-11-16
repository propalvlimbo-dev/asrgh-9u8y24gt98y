# install-official.ps1
# Stavit VSYU sborku (20 modov + biblioteki + motion blur) v papku mods
# ofitsialnogo launchera: C:\Users\<ty>\AppData\Roaming\.minecraft\mods
#
# Zapusk (odin variant iz treh):
#   1) iex (iwr 'https://raw.githubusercontent.com/propalvlimbo-dev/asrgh-9u8y24gt98y/main/pack-clean/install-official.ps1' -UseBasicParsing).Content
#   2) pravym klikom -> "Vypolnit s pomoshchyu PowerShell"
#   3) powershell -NoProfile -Command "& { . 'C:\put\install-official.ps1' }"
#
# Drugoe raspolozhenie .minecraft:
#   powershell -NoProfile -File .\install-official.ps1 "D:\.minecraft"
#   (put peredaetsya pervym argumentom)

$ErrorActionPreference = 'Continue'
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}
$PSDefaultParameterValues['Invoke-WebRequest:UseBasicParsing'] = $true

$game = '1.21.11'

# --- kuda stavit ---
$mcDir = ''
if ($args.Count -ge 1 -and $args[0]) { $mcDir = $args[0] }
elseif ($env:MC_DIR) { $mcDir = $env:MC_DIR }
else { $mcDir = Join-Path $env:APPDATA '.minecraft' }

$modsDir = Join-Path $mcDir 'mods'
if (-not (Test-Path $mcDir)) {
    Write-Host "NE NAYDENA papka: $mcDir" -ForegroundColor Red
    Write-Host 'Ukazhi put: powershell -NoProfile -File .\install-official.ps1 "D:\.minecraft"' -ForegroundColor Yellow
    exit 1
}
New-Item -ItemType Directory -Force -Path $modsDir | Out-Null

$ua = @{ 'User-Agent' = 'pvp-clean/1.0 (github.com/propalvlimbo-dev/asrgh-9u8y24gt98y)' }
$gv = [uri]::EscapeDataString('["' + $game + '"]')
$ld = [uri]::EscapeDataString('["fabric"]')

# --- chto stavit ---
$roots = @(
    @{ Slug = 'fabric-api';            Why = 'baza dlya vseh modov' },
    @{ Slug = 'sodium';                Why = 'render-dvizhok: +fps, rovnyy frame time' },
    @{ Slug = 'lithium';               Why = 'optimizatsiya logiki igry' },
    @{ Slug = 'ferrite-core';          Why = 'menshe pamyati i GC-pauz' },
    @{ Slug = 'modernfix';             Why = 'fiksy utechek i bystryy zagruz' },
    @{ Slug = 'krypton';               Why = 'set: menshe laga paketov' },
    @{ Slug = 'immediatelyfast';       Why = 'bystryy render HUD i teksta' },
    @{ Slug = 'entityculling';         Why = 'ne risuet sushchnosti za spino' },
    @{ Slug = 'scalablelux';           Why = 'bystroe osveshchenie' },
    @{ Slug = 'ixeris';                Why = 'menshe input lag' },
    @{ Slug = 'tick-sync';             Why = 'hit-reg: pozitsii ranshe' },
    @{ Slug = 'sodium-extra';          Why = 'mipmapy, AF, chastitsy, oblaka' },
    @{ Slug = 'reeses-sodium-options'; Why = 'menyu nastroek Sodium' },
    @{ Slug = 'fullscreen-tweaks';     Why = 'borderless dlya OBS' },
    @{ Slug = 'hitcolorx';             Why = 'tsvet vspyshki urona' },
    @{ Slug = 'betterhurtcam';         Why = 'bez tryaski kamery' },
    @{ Slug = 'bactromod';             Why = 'malenkiy shchit, fire offset, yarkost' },
    @{ Slug = 'shieldscale';           Why = 'razmer shchita' },
    @{ Slug = 'modmenu';               Why = 'menyu nastroek modov' },
    @{ Slug = 'zoomify';               Why = 'zum' },
    @{ Slug = 'natural-motion-blur';   Why = 'motion blur (plavnoe dvizhenie)' }
)

function Get-BySlug([string]$slug) {
    # berem do 20 versiy i predpochitaem stabilnyy reliz (bez beta/alpha)
    $u = "https://api.modrinth.com/v2/project/$slug/version?game_versions=$gv&loaders=$ld&limit=20"
    $r = @(Invoke-RestMethod -Uri $u -Headers $ua -Method Get)
    if ($r.Count -eq 0) { throw "net versii pod $game" }
    $stable = $r | Where-Object { $_.version_type -eq 'release' } | Select-Object -First 1
    if ($stable) { return $stable }
    return $r[0]
}
function Get-ById([string]$id) { return Invoke-RestMethod -Uri "https://api.modrinth.com/v2/version/$id" -Headers $ua -Method Get }
function Get-ByProject([string]$pid) {
    $u = "https://api.modrinth.com/v2/project/$pid/version?game_versions=$gv&loaders=$ld&limit=20"
    $r = @(Invoke-RestMethod -Uri $u -Headers $ua -Method Get)
    if ($r.Count -eq 0) { throw "net versii pod $game" }
    $stable = $r | Where-Object { $_.version_type -eq 'release' } | Select-Object -First 1
    if ($stable) { return $stable }
    return $r[0]
}
function Get-File($v) {
    $f = $v.files | Where-Object { $_.primary } | Select-Object -First 1
    if (-not $f) { $f = $v.files | Select-Object -First 1 }
    if (-not $f) { throw 'u versii net faylov' }
    return $f
}

# --- chistka musora: bibliotechnye jar-fayly, kotorye ne dolzhny lezhat v mods ---
$junk = @('joml*.jar','*sources*.jar','*-dev.jar')
foreach ($j in $junk) {
    Get-ChildItem $modsDir -Filter $j -ErrorAction SilentlyContinue | ForEach-Object {
        Remove-Item $_.FullName -Force
        Write-Host ("  udalil musor: {0}" -f $_.Name) -ForegroundColor DarkYellow
    }
}

Write-Host "============================================================" -ForegroundColor White
Write-Host "  PvP Clean $game -> ofitsialnyy launcher" -ForegroundColor White
Write-Host "  Papka mods: $modsDir" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor White

$queue  = New-Object System.Collections.Queue
$seen   = @{}
$added  = New-Object System.Collections.ArrayList
$errors = New-Object System.Collections.ArrayList

foreach ($m in $roots) { $queue.Enqueue([pscustomobject]@{ Kind = 'slug'; Value = $m.Slug; Why = $m.Why }) }

$guard = 0
while ($queue.Count -gt 0) {
    $guard++
    if ($guard -gt 150) { break }
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
            for ($a = 1; $a -le 3; $a++) {
                try { Invoke-WebRequest -Uri $file.url -OutFile $dest -Headers $ua; break }
                catch { if ($a -eq 3) { throw }; Start-Sleep -Milliseconds 900 }
            }
            $mb = [math]::Round($file.size / 1048576, 1)
            Write-Host ("  +    {0} {1} - {2} MB" -f $item.Value, $v.version_number, $mb) -ForegroundColor Green
            [void]$added.Add([pscustomobject]@{ Slug = $item.Value; Version = $v.version_number; File = $file.filename; Why = $item.Why })
        }

        foreach ($dep in @($v.dependencies)) {
            if (-not $dep) { continue }
            if ($dep.dependency_type -ne 'required') { continue }
            if ($dep.version_id)     { $queue.Enqueue([pscustomobject]@{ Kind = 'version'; Value = $dep.version_id; Why = 'zavisimost' }) }
            elseif ($dep.project_id) { $queue.Enqueue([pscustomobject]@{ Kind = 'project'; Value = $dep.project_id; Why = 'zavisimost' }) }
        }
    } catch {
        [void]$errors.Add([pscustomobject]@{ Slug = $item.Value; Error = $_.Exception.Message })
        Write-Host ("  !    {0} : {1}" -f $item.Value, $_.Exception.Message) -ForegroundColor Yellow
    }
}

# --- pamyatka + spisok ---
$listPath = Join-Path $mcDir 'PVP-CLEAN-MODS.txt'
$lines = New-Object System.Collections.ArrayList
[void]$lines.Add("PvP Clean $game - ustanovleno $(Get-Date -Format 'yyyy-MM-dd HH:mm')")
[void]$lines.Add('')
[void]$lines.Add('Chto nastroit v igre (Mod Menu):')
[void]$lines.Add('  BactroMod: Brightness 15, Pumpkin OFF, Fire -100, Shield -30, Fog OFF')
[void]$lines.Add('  BetterHurtCam: Hurtcam OFF')
[void]$lines.Add('  Custom Shield Scale: 0.5')
[void]$lines.Add('  HitColor X: tsvet vspyshki')
[void]$lines.Add('  Natural Motion Blur: sila 0.3-0.5 (ili vyklyuchi dlya PvP)')
[void]$lines.Add('')
[void]$lines.Add('Ustanovleno:')
foreach ($a in $added) { [void]$lines.Add(("  {0} {1} - {2}" -f $a.Slug, $a.Version, $a.Why)) }
if ($errors.Count -gt 0) {
    [void]$lines.Add('')
    [void]$lines.Add('Ne ustanovilos:')
    foreach ($e in $errors) { [void]$lines.Add(("  {0} - {1}" -f $e.Slug, $e.Error)) }
}
Set-Content -Path $listPath -Value ($lines -join "`r`n") -Encoding UTF8

Write-Host ''
Write-Host ("Dobavleno: {0}, oshibok: {1}" -f $added.Count, $errors.Count) -ForegroundColor Green
Write-Host ("Spisok: {0}" -f $listPath) -ForegroundColor DarkGray
# --- proverka obyazatelnyh bibliotek ---
$mustHave = @('ukulib','yacl','fabric-language-kotlin')
Write-Host ''
Write-Host 'Proverka bibliotek:' -ForegroundColor Cyan
$jars = @(Get-ChildItem $modsDir -Filter *.jar -ErrorAction SilentlyContinue)
foreach ($m in $mustHave) {
    $found = $jars | Where-Object { $_.Name -like ($m + '*') }
    if ($found) { Write-Host ("  OK  {0}" -f $found[0].Name) -ForegroundColor Green }
    else { Write-Host ("  NET {0} - zapusti skript povtorno ili skachay vruchnuyu s modrinth.com" -f $m) -ForegroundColor Red }
}
Write-Host ("  Vsego .jar v mods: {0}" -f $jars.Count) -ForegroundColor DarkGray

Write-Host ''
Write-Host 'Dalshe: ofitsialnyy launcher -> profil fabric-loader-1.21.11 -> Igra.' -ForegroundColor White
Write-Host 'Esli profilya net: fabricmc.net/use/installer -> 1.21.11 -> Install.' -ForegroundColor White
exit 0
