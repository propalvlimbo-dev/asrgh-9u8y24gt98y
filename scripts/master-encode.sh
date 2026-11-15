#!/usr/bin/env bash
# master-encode.sh — собрать «мастер» из записи OBS: высокое качество, CFR, Rec.709/Limited.
#
# Использование:
#   bash scripts/master-encode.sh вход.mkv выход.mp4            # x264 CRF 14 (8 бит, совместимо)
#   bash scripts/master-encode.sh вход.mkv выход.mp4 16         # x264 CRF 16 (чуть меньше файл)
#   bash scripts/master-encode.sh вход.mkv выход.mp4 17 hevc    # x265 CRF 17, 10 бит
#   bash scripts/master-encode.sh вход.mkv выход.mov prores     # ProRes 422 HQ (архив)
#
# Особенности:
#   • -vf fps=60 фиксирует CFR (лечит VFR-источники)
#   • цветовые метаданные прописываются явно (bt709 / tv)
#   • звук: AAC 320k (для мастеров) либо PCM для prores
set -euo pipefail

usage() {
  sed -n '2,15p' "$0"
  exit 1
}

[ "$#" -ge 2 ] || usage

IN="$1"
OUT="$2"
CRF="${3:-14}"
MODE="${4:-x264}"

command -v ffmpeg >/dev/null 2>&1 || { echo "ОШИБКА: нужен ffmpeg" >&2; exit 1; }
[ -f "$IN" ] || { echo "ОШИБКА: нет файла $IN" >&2; exit 1; }

COLOR=(-colorspace bt709 -color_primaries bt709 -color_trc bt709 -color_range tv)
COMMON=(-map 0:v:0 -map 0:a? -vf "fps=60" "${COLOR[@]}")

case "$MODE" in
  x264)
    echo "→ x264 CRF $CRF, 8 бит, CFR 60"
    ffmpeg -hide_banner -i "$IN" "${COMMON[@]}" \
      -c:v libx264 -preset slow -crf "$CRF" -pix_fmt yuv420p \
      -profile:v high -level 5.2 -x264-params "keyint=120:min-keyint=60:bframes=3" \
      -c:a aac -b:a 320k -ar 48000 "$OUT"
    ;;
  hevc|x265)
    echo "→ x265 CRF $CRF, 10 бит, CFR 60"
    ffmpeg -hide_banner -i "$IN" "${COMMON[@]}" \
      -c:v libx265 -preset slow -crf "$CRF" -pix_fmt yuv420p10le \
      -x265-params "profile=main10:keyint=120:bframes=4" \
      -c:a aac -b:a 384k -ar 48000 "$OUT"
    ;;
  prores)
    echo "→ ProRes 422 HQ (архив), CFR 60"
    ffmpeg -hide_banner -i "$IN" "${COMMON[@]}" \
      -c:v prores_ks -profile:v 3 -pix_fmt yuv422p10le \
      -c:a pcm_s24le -ar 48000 "$OUT"
    ;;
  *)
    echo "ОШИБКА: неизвестный режим '$MODE' (x264 | hevc | prores)" >&2
    exit 1
    ;;
esac

echo "Готово: $OUT"
echo "Проверь: bash scripts/qc-check.sh \"$OUT\""
