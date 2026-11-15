#Requires -Version 5.1
<#
  install.ps1 - ustanovshchik sborki "PvP Clean 1.21.11"
  =====================================================
  Chto delaet:
    1) nahodit Prism Launcher i sozdaet gotovyy instans "PvP Clean 1.21.11";
    2) skachivaet s Modrinth aktualnye versii modov pod Minecraft 1.21.11 (Fabric);
    3) kladet options.txt s nastroykami "chistyy ekran + idealnaya kartinka";
    4) pishet pamyatku, chto nastroit v igre za 2 minuty.

  Zapusk:
    dvoynoy klik po install.bat
    ili: powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1

  Parametry:
    -GameVersion      versiya igry (po umolchaniyu 1.21.11)
    -InstanceName     imya instansa v Prism
    -PrismInstances   papka instances (po umolchaniyu %APPDATA%\PrismLauncher\instances)
    -ModsOnly         ne sozdavat instans, tolko zalit mody v -ModsPath
    -ModsPath         papka mods (dlya -ModsOnly)
    -WithFlashback    dopolnitelno postavit Flashback (rendering klipov 4K/120, ~200 MB)
    -NoOptions        ne trogat options.txt
#>
[CmdletBinding()]
param(
    [string]$GameVersion    = '1.21.11',
    [string]$InstanceName   = 'PvP Clean 1.21.11',
    [string]$PrismInstances = '',
    [string]$ModsPath       = '',
    [switch]$ModsOnly,
    [switch]$WithFlashback,
    [switch]$NoOptions
)

$ErrorActionPreference = 'Stop'
$ProgressPreference    = 'SilentlyContinue'
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}

$UA = @{ 'User-Agent' = 'arena-pvp-clean-installer/1.0 (github.com/propalvlimbo-dev/asrgh-9u8y24gt98y)' }

function Write-Step([string]$text) { Write-Host "`n=== $text" -ForegroundColor Cyan }
function Write-Ok([string]$text)   { Write-Host "  [ok] $text"   -ForegroundColor Green }
function Write-Note([string]$text) { Write-Host "  [!]  $text"   -ForegroundColor Yellow }
function Write-Bad([string]$text)  { Write-Host "  [x]  $text"   -ForegroundColor Red }

# ---------------------------------------------------------------------------
# Spisok modov: slug na Modrinth + zachem on tut
# ---------------------------------------------------------------------------
$Mods = @(
    # osnova / proizvoditelnost / zaderzhka
    @{ Slug = 'fabric-api';             Why = 'baza dlya vseh modov' }
    @{ Slug = 'sodium';                 Why = 'render-dvizhok: +fps, rovnyy frame time' }
    @{ Slug = 'lithium';                Why = 'optimizatsiya igrovoy logiki' }
    @{ Slug = 'ferrite-core';           Why = 'menshe pamyati i GC-pauz' }
    @{ Slug = 'modernfix';              Why = 'fiksy utechek, bystryy zagruz' }
    @{ Slug = 'krypton';                Why = 'setevoy stek: menshe laga paketov' }
    @{ Slug = 'immediatelyfast';        Why = 'bystryy render HUD i teksta' }
    @{ Slug = 'entityculling';          Why = 'ne risuet sushchnosti za spino' }
    @{ Slug = 'scalablelux';            Why = 'bystroe osveshchenie, menshe stutterov' }
    @{ Slug = 'ixeris';                 Why = 'vvod vne render-potoka: menshe zaderzhki' }
    @{ Slug = 'tick-sync';              Why = 'igroki dvigayutsya na ekrane ranshe (hit-reg)' }

    # kartinka / chistota ekrana
    @{ Slug = 'sodium-extra';           Why = 'mipmapy 4x, AF 16x, chastitsy, oblaka, tuman' }
    @{ Slug = 'reeses-sodium-options';  Why = 'normalnoe menyu nastroyk Sodium' }
    @{ Slug = 'fullscreen-tweaks';      Why = 'borderless-fullscreen, druzhit s OBS' }

    # PvP-vizual (rovno to, chto nuzhno)
    @{ Slug = 'hitcolorx';              Why = 'tsvet vspyshki urona - edinstvennoe na ekrane' }
    @{ Slug = 'betterhurtcam';          Why = 'ubiraet tryasku kamery pri urone' }
    @{ Slug = 'bactromod';              Why = 'malenkiy shchit, fire offset, yarkost, bez tykvy, fog off' }
    @{ Slug = 'shieldscale';            Why = 'tochnyy razmer shchita' }
    @{ Slug = 'modmenu';                Why = 'menyu nastroyk dlya etih modov' }

    # po zhelaniyu
    @{ Slug = 'zoomify';                Why = 'zum dlya proverki sglazhivaniya' }
)

# ---------------------------------------------------------------------------
# Puti
# ---------------------------------------------------------------------------
if (-not $PrismInstances -or $PrismInstances.Trim() -eq '') {
    $PrismInstances = Join-Path $env:APPDATA 'PrismLauncher\instances'
}

Write-Host "============================================================" -ForegroundColor White
Write-Host "  Sborka PvP Clean $GameVersion" -ForegroundColor White
Write-Host "  chistyy ekran + malenkiy shchit + bez tryaski kamery" -ForegroundColor White
Write-Host "  optimizatsiya + nizkaya zaderzhka" -ForegroundColor White
Write-Host "============================================================" -ForegroundColor White

if ($ModsOnly) {
    if (-not $ModsPath) {
        Write-Bad 'Dlya -ModsOnly nuzhen -ModsPath (papka mods tvogo instansa).'
        exit 1
    }
    $modsDir      = $ModsPath
    $instanceRoot = $null
    $mcDir        = $null
} else {
    $instanceRoot = Join-Path $PrismInstances $InstanceName
    $mcDir        = Join-Path $instanceRoot 'minecraft'
    $modsDir      = Join-Path $mcDir 'mods'
}

New-Item -ItemType Directory -Force -Path $modsDir | Out-Null

# ---------------------------------------------------------------------------
# Funktsii Modrinth
# ---------------------------------------------------------------------------
function Get-ModVersion {
    param([string]$Slug)

    $gv = [uri]::EscapeDataString('["' + $GameVersion + '"]')
    $ld = [uri]::EscapeDataString('["fabric"]')
    $uri = "https://api.modrinth.com/v2/project/$Slug/version?game_versions=$gv&loaders=$ld&limit=1"

    $vers = @()
    for ($attempt = 1; $attempt -le 3; $attempt++) {
        try {
            $vers = @(Invoke-RestMethod -Uri $uri -Headers $UA -Method Get)
            break
        } catch {
            if ($attempt -eq 3) { throw }
            Start-Sleep -Milliseconds 700
        }
    }
    if ($vers.Count -eq 0) { throw "net versii pod Minecraft $GameVersion (Fabric)" }

    $v = $vers[0]
    $file = $v.files | Where-Object { $_.primary } | Select-Object -First 1
    if (-not $file) { $file = $v.files | Select-Object -First 1 }
    if (-not $file) { throw 'u versii net faylov' }

    return [pscustomobject]@{
        Version = $v.version_number
        File    = $file.filename
        Url     = $file.url
        SizeMB  = [math]::Round($file.size / 1048576, 1)
    }
}

function Save-RemoteFile {
    param([string]$Url, [string]$Destination)
    for ($attempt = 1; $attempt -le 3; $attempt++) {
        try {
            Invoke-WebRequest -Uri $Url -OutFile $Destination -Headers $UA -UseBasicParsing
            return
        } catch {
            if ($attempt -eq 3) { throw }
            Start-Sleep -Milliseconds 900
        }
    }
}

# ---------------------------------------------------------------------------
# Skachivanie
# ---------------------------------------------------------------------------
Write-Step "Skachivanie modov (s avtomaticheskoy podtyazhkoy zavisimostey)"

$gvParam = [uri]::EscapeDataString('["' + $GameVersion + '"]')
$ldParam = [uri]::EscapeDataString('["fabric"]')

function Get-VersionBySlug([string]$Slug) {
    $uri = "https://api.modrinth.com/v2/project/$Slug/version?game_versions=$gvParam&loaders=$ldParam&limit=1"
    $r = @(Invoke-RestMethod -Uri $uri -Headers $UA -Method Get)
    if ($r.Count -eq 0) { throw "net versii pod Minecraft $GameVersion" }
    return $r[0]
}

function Get-VersionById([string]$VersionId) {
    return Invoke-RestMethod -Uri "https://api.modrinth.com/v2/version/$VersionId" -Headers $UA -Method Get
}

function Get-VersionByProjectId([string]$ProjectId) {
    $uri = "https://api.modrinth.com/v2/project/$ProjectId/version?game_versions=$gvParam&loaders=$ldParam&limit=1"
    $r = @(Invoke-RestMethod -Uri $uri -Headers $UA -Method Get)
    if ($r.Count -eq 0) { throw "net versii pod Minecraft $GameVersion" }
    return $r[0]
}

function Get-PrimaryFile($Version) {
    $f = $Version.files | Where-Object { $_.primary } | Select-Object -First 1
    if (-not $f) { $f = $Version.files | Select-Object -First 1 }
    if (-not $f) { throw 'u versii net faylov' }
    return $f
}

$installed = New-Object System.Collections.ArrayList
$failed    = New-Object System.Collections.ArrayList
$seen      = @{}

$queue = New-Object System.Collections.Queue
foreach ($m in $Mods) {
    $queue.Enqueue([pscustomobject]@{ Kind = 'slug'; Value = $m.Slug; Why = $m.Why })
}
if ($WithFlashback) {
    $queue.Enqueue([pscustomobject]@{ Kind = 'slug'; Value = 'flashback'; Why = 'rendering klipov 4K/120' })
}

$guard = 0
while ($queue.Count -gt 0) {
    $guard++
    if ($guard -gt 120) { Write-Note 'ostanovilsya: bolshe 120 komponentov (zashchita ot retsii)'; break }

    $item = $queue.Dequeue()
    $label = $item.Value

    try {
        switch ($item.Kind) {
            'slug'      { $v = Get-VersionBySlug    -Slug $item.Value }
            'version'   { $v = Get-VersionById      -VersionId $item.Value }
            'project'   { $v = Get-VersionByProjectId -ProjectId $item.Value }
            default     { throw "neizvestnyy tip: $($item.Kind)" }
        }

        $projectKey = $v.project_id
        if ($projectKey -and $seen.ContainsKey($projectKey)) { continue }
        if ($projectKey) { $seen[$projectKey] = $true }

        $file = Get-PrimaryFile -Version $v
        $dest = Join-Path $modsDir $file.filename
        $sizeMb = [math]::Round($file.size / 1048576, 1)

        if (Test-Path $dest) {
            Write-Ok ("{0} - uzhe est" -f $file.filename)
        } else {
            for ($attempt = 1; $attempt -le 3; $attempt++) {
                try { Invoke-WebRequest -Uri $file.url -OutFile $dest -Headers $UA -UseBasicParsing; break }
                catch { if ($attempt -eq 3) { throw }; Start-Sleep -Milliseconds 900 }
            }
            Write-Ok ("{0} {1} - {2} MB" -f $item.Value, $v.version_number, $sizeMb)
        }

        [void]$installed.Add([pscustomobject]@{
            Slug    = $item.Value
            Name    = $v.name
            Version = $v.version_number
            File    = $file.filename
            Why     = $item.Why
        })

        foreach ($dep in @($v.dependencies)) {
            if (-not $dep) { continue }
            if ($dep.dependency_type -ne 'required') { continue }
            if ($dep.version_id) {
                $queue.Enqueue([pscustomobject]@{ Kind = 'version'; Value = $dep.version_id; Why = 'zavisimost' })
            } elseif ($dep.project_id) {
                $queue.Enqueue([pscustomobject]@{ Kind = 'project'; Value = $dep.project_id; Why = 'zavisimost' })
            }
        }
    } catch {
        [void]$failed.Add([pscustomobject]@{ Slug = $label; Error = $_.Exception.Message })
        Write-Note ("{0} - propushchen: {1}" -f $label, $_.Exception.Message)
    }
}

# ---------------------------------------------------------------------------
# Instans Prism
# ---------------------------------------------------------------------------
if ($instanceRoot) {
    Write-Step "Sozdanie instansa Prism: $InstanceName"

    if (-not (Test-Path $PrismInstances)) {
        Write-Note "papka $PrismInstances ne naydena. Esli Prism ustanovlen v druguyu papku, zapusti s -PrismInstances `"put`"."
    }

    $loaderVersion = ''
    try {
        $meta = @(Invoke-RestMethod -Uri "https://meta.fabricmc.net/v2/versions/loader/$GameVersion" -Headers $UA -Method Get)
        $stableLoader = $meta | Where-Object { $_.loader.stable -eq $true } | Select-Object -First 1
        if ($stableLoader) { $loaderVersion = $stableLoader.loader.version }
        elseif ($meta.Count -gt 0) { $loaderVersion = $meta[0].loader.version }
        if ($loaderVersion) { Write-Ok "Fabric Loader: $loaderVersion" }
    } catch {
        Write-Note "ne udalos uznat versiyu Fabric Loader ($($_.Exception.Message)). Instans sozdam bez nego."
    }

    New-Item -ItemType Directory -Force -Path $mcDir | Out-Null
    New-Item -ItemType Directory -Force -Path (Join-Path $mcDir 'resourcepacks') | Out-Null

    $components = New-Object System.Collections.ArrayList
    [void]$components.Add([ordered]@{ cachedName = 'Minecraft'; uid = 'net.minecraft'; version = $GameVersion; important = $true })
    if ($loaderVersion) {
        [void]$components.Add([ordered]@{ cachedName = 'Fabric Loader'; uid = 'net.fabricmc.fabric-loader'; version = $loaderVersion })
    }
    $mmcPack = [ordered]@{ formatVersion = 1; components = @($components) }
    $mmcPack | ConvertTo-Json -Depth 6 | Set-Content -Path (Join-Path $instanceRoot 'mmc-pack.json') -Encoding ASCII

    # -Xms/-Xmx NE ukazyvaem: pamyat zadayut MinMemAlloc/MaxMemAlloc, inache Prism rugaetsya predprezhdeniem
    $jvm = '-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:InitiatingHeapOccupancyPercent=15 -XX:SurvivorRatio=32 -XX:MaxTenuringThreshold=1'

    $instanceCfg = @(
        'InstanceType=OneSix'
        'iconKey=default'
        ('name=' + $InstanceName)
        'OverrideMemory=true'
        'MinMemAlloc=4096'
        'MaxMemAlloc=10240'
        'OverrideJavaArgs=true'
        ('JvmArgs=' + $jvm)
        'OverrideConsole=false'
        'JoinServerOnLaunch=false'
        'AutoUpdate=false'
    ) -join "`r`n"
    Set-Content -Path (Join-Path $instanceRoot 'instance.cfg') -Value ($instanceCfg + "`r`n") -Encoding ASCII
    Write-Ok 'mmc-pack.json + instance.cfg zapisany'

    if (-not $NoOptions) {
        $optPath = Join-Path $mcDir 'options.txt'
        if (Test-Path $optPath) {
            Copy-Item $optPath ($optPath + '.bak') -Force
            Write-Note 'staryy options.txt sohranen kak options.txt.bak'
        }
        $options = @(
            'graphicsMode:1'
            'ao:true'
            'entityShadows:true'
            'mipmapLevels:4'
            'biomeBlendRadius:2'
            'renderClouds:"true"'
            'particles:2'
            'renderDistance:12'
            'simulationDistance:8'
            'guiScale:3'
            'gamma:1.0'
            'fovEffectScale:0.0'
            'screenEffectScale:0.0'
            'enableVsync:false'
            'maxFps:240'
            'useNativeTransport:true'
            'syncChunkWrites:false'
            'narrator:0'
            'tutorialStep:none'
            'skipMultiplayerWarning:true'
            'autoJump:false'
            'toggleSprint:true'
            'soundCategory_music:0.0'
        ) -join "`r`n"
        Set-Content -Path $optPath -Value ($options + "`r`n") -Encoding ASCII
        Write-Ok 'options.txt: chastitsy minimalnye, VSync off, 240 fps, FOV-effekty off'
    }

    $readmePath = Join-Path $mcDir 'PVP-CLEAN-READ-ME.txt'
    $rl = New-Object System.Collections.ArrayList
    [void]$rl.Add("Sborka PvP Clean $GameVersion - chto nastroit v igre za 2 minuty")
    [void]$rl.Add('')
    [void]$rl.Add('1) Mod Menu -> BactroMod:')
    [void]$rl.Add('     Brightness Boost = 15')
    [void]$rl.Add('     Pumpkin Blur    = OFF')
    [void]$rl.Add('     Fire Offset     = -100')
    [void]$rl.Add('     Shield Offset   = -30')
    [void]$rl.Add('     Fog             = OFF')
    [void]$rl.Add('2) Mod Menu -> BetterHurtCam: Hurtcam Enabled = OFF  (net tryaski kamery)')
    [void]$rl.Add('3) Mod Menu -> Custom Shield Scale: scale = 0.5, height = -10')
    [void]$rl.Add('4) Mod Menu -> HitColor X: tsvet vspyshki urona (naprimer beliy ili krasnyy)')
    [void]$rl.Add('5) Options -> Accessibility: Camera Bobbing 0%, Hand Bobbing 40%')
    [void]$rl.Add('6) Video Settings: chastitsy Minimal (uzhe stoit), FOV 80-90, GUI Scale 3')
    [void]$rl.Add('7) Video Settings / Sodium Extra: Mipmap 4x, Anisotropic 16x, Clouds Fancy')
    [void]$rl.Add('8) NVIDIA: DSR/DLDSR 2.25x, Smoothness 15%, VSync off, Low Latency On')
    [void]$rl.Add('9) OBS: NVENC AV1, CQP 16-18, 60 fps, P010, Rec.709 Limited')
    [void]$rl.Add('')
    [void]$rl.Add('Ustanovlennye mody:')
    foreach ($i in $installed) { [void]$rl.Add(('  - {0} {1} - {2}' -f $i.Slug, $i.Version, $i.Why)) }
    if ($failed.Count -gt 0) {
        [void]$rl.Add('')
        [void]$rl.Add('Ne ustanovilis (dokachay vruchnuyu s modrinth.com):')
        foreach ($f in $failed) { [void]$rl.Add(('  - {0} ({1})' -f $f.Slug, $f.Error)) }
    }
    Set-Content -Path $readmePath -Value ($rl -join "`r`n") -Encoding UTF8
    Write-Ok "pamyatka: $readmePath"
}

# ---------------------------------------------------------------------------
# Itog
# ---------------------------------------------------------------------------
Write-Step 'Itog'
Write-Host ("  Ustanovleno modov: {0}" -f $installed.Count) -ForegroundColor Green
if ($failed.Count -gt 0) {
    Write-Host ("  Ne ustanovilos:   {0}" -f $failed.Count) -ForegroundColor Yellow
    foreach ($f in $failed) { Write-Host ("    - {0}: {1}" -f $f.Slug, $f.Error) -ForegroundColor DarkYellow }
}

if (-not $ModsOnly) {
    Write-Host ''
    Write-Host 'Dalshe:' -ForegroundColor White
    Write-Host ("  1. Otkroy Prism Launcher - instans `"{0}`" uzhe v spiske." -f $InstanceName) -ForegroundColor White
    Write-Host '  2. Zapusti igru (pervyy zapusk skachaet Minecraft i Fabric Loader).' -ForegroundColor White
    Write-Host '  3. Mod Menu -> proydi 6 punktov iz PVP-CLEAN-READ-ME.txt' -ForegroundColor White
    Write-Host ''
    Write-Host ("  Papka instansa: {0}" -f $instanceRoot) -ForegroundColor DarkGray
    Write-Host ("  Mody:           {0}" -f $modsDir) -ForegroundColor DarkGray
} else {
    Write-Host ''
    Write-Host ("Mody zality v: {0}" -f $modsDir) -ForegroundColor White
}

if ($failed.Count -gt 0) { exit 2 } else { exit 0 }
