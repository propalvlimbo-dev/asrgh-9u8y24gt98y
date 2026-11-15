#!/usr/bin/env bash
# proxies.sh — сделать прокси для монтажа в Premiere (если AV1/HEVC 10 бит тормозит таймлайн).
#
# Использование:
#   bash scripts/proxies.sh ./footage ./proxies
#
# Что делает: для каждого видео в ./footage создаёт 1280x720 H.264 (или ProRes Proxy),
# с тем же fps и теми же именами (суффикс _proxy).
#
# Как подключить в Premiere:
#   1) Импортируй оригиналы в проект.
#   2) Выдели клипы → правый клик → Proxy → Attach Proxies → выбери папку ./proxies.
#   3) Кнопка Toggle Proxies для переключения. На экспорт это не влияет — Premiere берёт оригиналы.
set -euo pipefail

SRC="${1:-}"
DST="${2:-}"
if [ -z "$SRC" ] || [ -z "$DST" ]; then
  sed -n '2,12p' "$0"
  exit 1
fi

command -v ffmpeg >/dev/null 2>&1 || { echo "ОШИБКА: нужен ffmpeg" >&2; exit 1; }
[ -d "$SRC" ] || { echo "ОШИБКА: нет папки $SRC" >&2; exit 1; }
mkdir -p "$DST"

shopt -s nullglob nocaseglob
count=0
for f in "$SRC"/*.{mkv,mp4,mov,avi,webm}; do
  base="$(basename "${f%.*}")"
  out="$DST/${base}_proxy.mp4"
  if [ -f "$out" ]; then
    echo "· уже есть: $out"
    continue
  fi
  echo "→ прокси: $f"
  ffmpeg -hide_banner -loglevel error -stats -i "$f" \
    -vf "scale=-2:720" \
    -c:v libx264 -preset veryfast -crf 23 -pix_fmt yuv420p \
    -c:a aac -b:a 192k -ar 48000 \
    "$out"
  count=$((count + 1))
done

echo
echo "Готово прокси: $count → $DST"
echo "В Premiere: выдели клипы → Proxy → Attach Proxies → папка $DST"
