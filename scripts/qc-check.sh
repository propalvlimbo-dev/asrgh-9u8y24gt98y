#!/usr/bin/env bash
# qc-check.sh — проверка качества видеофайла: fps, битрейт, bpp, VFR, цвет, кодеки.
#
# Использование:
#   bash scripts/qc-check.sh запись.mkv [ещё_файлы...]
#
# Требует: ffprobe (из FFmpeg) и python3.
# Что смотреть:
#   • FPS: avg ≈ r_frame_rate, иначе VFR (в Premiere будут рывки)
#   • bpp: >= 0.20 для финала, >= 0.50 для записи
#   • color_range = tv (Limited), color_space = bt709
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPORT="$SCRIPT_DIR/lib/qc_report.py"

if ! command -v ffprobe >/dev/null 2>&1; then
  echo "ОШИБКА: не найден ffprobe. Установи FFmpeg: https://ffmpeg.org/download.html" >&2
  exit 1
fi
if ! command -v python3 >/dev/null 2>&1; then
  echo "ОШИБКА: не найден python3." >&2
  exit 1
fi
if [ "$#" -eq 0 ]; then
  sed -n '2,13p' "$0"
  exit 1
fi

for f in "$@"; do
  if [ ! -f "$f" ]; then
    echo "ПРОПУСК: файл не найден: $f" >&2
    continue
  fi
  ffprobe -v error -show_streams -show_format -of json "$f" \
    | python3 "$REPORT" "$f"
done

echo "Рекомендации:"
echo "  • запись: bpp >= 0.50, CFR 60/120, Limited, Rec.709, 10 бит для HEVC/AV1"
echo "  • финал : bpp >= 0.20; 2160p60 → 70–90 Мбит/с H.264 / 50–70 Мбит/с HEVC"
echo "  • если VFR — перегони: bash scripts/master-encode.sh вход.mkv выход.mp4"
