#!/usr/bin/env bash
# install.sh — Linux/macOS версия установщика «PvP Clean 1.21.11».
#
# Скачивает актуальные версии модов с Modrinth под Minecraft 1.21.11 (Fabric)
# в указанную папку mods.
#
# Использование:
#   ./install.sh -d ~/.local/share/PrismLauncher/instances/"PvP Clean 1.21.11"/minecraft/mods
#   ./install.sh -d ~/mc/mods --flashback
#   ./install.sh -d ~/mc/mods -g 1.21.11
#
# Требует: python3 (для HTTPS и JSON).
set -euo pipefail

GAME="1.21.11"
DEST=""
FLASHBACK=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    -d|--dest) DEST="${2:-}"; shift 2 ;;
    -g|--game) GAME="${2:-}"; shift 2 ;;
    --flashback) FLASHBACK=1; shift ;;
    -h|--help) sed -n '2,14p' "$0"; exit 0 ;;
    *) echo "Неизвестный аргумент: $1" >&2; exit 1 ;;
  esac
done

[ -n "$DEST" ] || { echo "ОШИБКА: укажи папку mods через -d" >&2; sed -n '2,14p' "$0"; exit 1; }
command -v python3 >/dev/null 2>&1 || { echo "ОШИБКА: нужен python3" >&2; exit 1; }
mkdir -p "$DEST"

python3 - "$GAME" "$DEST" "$FLASHBACK" <<'PY'
import json, os, sys, time, urllib.parse, urllib.request

game, dest, flashback = sys.argv[1], sys.argv[2], sys.argv[3] == "1"

MODS = [
    ("fabric-api", "база для всех модов"),
    ("sodium", "рендер-движок: +fps"),
    ("lithium", "логика игры"),
    ("ferrite-core", "память / GC"),
    ("modernfix", "фиксы и загруз"),
    ("krypton", "сеть: меньше лага"),
    ("immediatelyfast", "HUD / текст"),
    ("entityculling", "отсечение сущностей"),
    ("scalablelux", "освещение"),
    ("ixeris", "меньше input lag"),
    ("tick-sync", "hit-reg / позиции"),
    ("sodium-extra", "мипмапы, AF, частицы"),
    ("reeses-sodium-options", "меню Sodium"),
    ("fullscreen-tweaks", "borderless для OBS"),
    ("hitcolorx", "цвет вспышки урона"),
    ("betterhurtcam", "без тряски камеры"),
    ("bactromod", "маленький щит, fire offset, яркость"),
    ("shieldscale", "размер щита"),
    ("modmenu", "меню настроек"),
    ("zoomify", "зум"),
]
if flashback:
    MODS.append(("flashback", "рендер клипов 4K/120"))

UA = {"User-Agent": "arena-pvp-clean-installer/1.0 (github.com/propalvlimbo-dev/asrgh-9u8y24gt98y)"}

def api(url):
    req = urllib.request.Request(url, headers=UA)
    with urllib.request.urlopen(req, timeout=30) as r:
        return json.loads(r.read().decode())

def latest(slug):
    gv = urllib.parse.quote('["%s"]' % game)
    ld = urllib.parse.quote('["fabric"]')
    url = f"https://api.modrinth.com/v2/project/{slug}/version?game_versions={gv}&loaders={ld}&limit=1"
    last = None
    for attempt in range(3):
        try:
            return api(url)
        except Exception as e:  # noqa: BLE001
            last = e
            time.sleep(0.8)
    raise last


ok, failed = [], []
print(f"\n=== Скачивание {len(MODS)} модов под Minecraft {game} ===\n")

for slug, why in MODS:
    try:
        vers = latest(slug)
        if not vers:
            raise RuntimeError(f"нет версии под {game}")
        v = vers[0]
        files = v.get("files") or []
        f = next((x for x in files if x.get("primary")), files[0] if files else None)
        if not f:
            raise RuntimeError("у версии нет файлов")
        path = os.path.join(dest, f["filename"])
        if os.path.exists(path):
            print(f"  [ok] {slug} — уже есть")
        else:
            req = urllib.request.Request(f["url"], headers=UA)
            with urllib.request.urlopen(req, timeout=120) as r, open(path, "wb") as out:
                out.write(r.read())
            size = f.get("size", 0) / 1024 / 1024
            print(f"  [ok] {slug} {v.get('version_number','')} — {size:.1f} МБ")
        ok.append((slug, v.get("version_number", ""), why))
    except Exception as e:  # noqa: BLE001
        failed.append((slug, str(e)))
        print(f"  [!]  {slug} — пропущен: {e}")

print(f"\n=== Итог: {len(ok)} установлено, {len(failed)} пропущено ===")
for slug, err in failed:
    print(f"  - {slug}: {err}")

if ok:
    note = os.path.join(os.path.dirname(dest.rstrip("/")), "PVP-CLEAN-READ-ME.txt")
    try:
        with open(note, "w", encoding="utf-8") as fh:
            fh.write(f"PvP Clean {game}\n\nЧто настроить в игре:\n")
            fh.write("1) BactroMod: Brightness 15, Pumpkin OFF, Fire -100, Shield -30, Fog OFF\n")
            fh.write("2) BetterHurtCam: OFF\n3) Custom Shield Scale: 0.5\n")
            fh.write("4) HitColor X: цвет вспышки\n5) Camera Bobbing 0%, Hand 40%\n")
            fh.write("6) Particles Minimal, FOV 80-90\n7) Mipmap 4x + AF 16x\n")
            fh.write("8) NVIDIA DSR 2.25x / OBS AV1 CQP 16-18\n\nМоды:\n")
            for slug, ver, why in ok:
                fh.write(f"  - {slug} {ver} — {why}\n")
        print(f"\nПамятка: {note}")
    except OSError:
        pass

sys.exit(0 if not failed else 2)
PY
