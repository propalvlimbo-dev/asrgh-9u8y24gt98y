#!/usr/bin/env bash
# upscale-4k.sh — аккуратный апскейл до 4K (Lanczos) без «звона».
#
# Использование:
#   bash scripts/upscale-4k.sh вход.mp4 выход-4k.mp4
#   bash scripts/upscale-4k.sh вход.mp4 выход-4k.mp4 3840 2160 0.25
#
# Аргументы:
#   1) вход            2) выход
#   3) ширина (по умолч. 3840)
#   4) высота (по умолч. 2160)
#   5) сила unsharp 0..0.5 (по умолч. 0.25; 0 = без шарпа — рекомендуется для Minecraft)
#
# Важно: это НЕ заменяет Topaz. Это «честный ресемплинг» для случаев, когда AI-апскейл недоступен.
# Для максимального качества используй Topaz Video AI (см. docs/07-post-upscale.md).
set -euo pipefail

usage() { sed -n '2,16p' "$0"; exit 1; }
[ "$#" -ge 2 ] || usage

IN="$1"
OUT="$2"
W="${3:-3840}"
H="${4:-2160}"
SHARP="${5:-0.25}"

command -v ffmpeg >/dev/null 2>&1 || { echo "ОШИБКА: нужен ffmpeg" >&2; exit 1; }
[ -f "$IN" ] || { echo "ОШИБКА: нет файла $IN" >&2; exit 1; }

VF="scale=${W}:${H}:flags=lanczos+accurate_rnd+full_chroma_int"
if awk "BEGIN{exit !($SHARP > 0)}"; then
  VF="${VF},unsharp=5:5:${SHARP}:5:5:0.0"
fi

echo "→ апскейл в ${W}x${H} (unsharp=${SHARP})"
ffmpeg -hide_banner -i "$IN" \
  -vf "$VF" \
  -c:v libx265 -preset slow -crf 17 -pix_fmt yuv420p10le \
  -x265-params "profile=main10:keyint=120:bframes=4" \
  -colorspace bt709 -color_primaries bt709 -color_trc bt709 -color_range tv \
  -c:a copy "$OUT"

echo "Готово: $OUT"
echo "Проверь: bash scripts/qc-check.sh \"$OUT\""
