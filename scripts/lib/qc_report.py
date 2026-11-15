#!/usr/bin/env python3
"""Парсер вывода ffprobe (JSON) для qc-check.sh.

Использование:
    ffprobe -v error -show_streams -show_format -of json file.mkv | python3 qc_report.py file.mkv
"""
import json
import sys
from fractions import Fraction


def rate(s: str) -> float:
    try:
        return float(Fraction(s))
    except Exception:
        return 0.0


def main() -> int:
    if len(sys.argv) < 2:
        print("usage: qc_report.py <path>  (JSON ffprobe на stdin)", file=sys.stderr)
        return 2

    path = sys.argv[1]
    try:
        data = json.load(sys.stdin)
    except json.JSONDecodeError as exc:
        print(f"  ОШИБКА: не удалось разобрать вывод ffprobe ({exc})", file=sys.stderr)
        return 1

    fmt = data.get("format", {}) or {}
    streams = data.get("streams", []) or []
    v = next((s for s in streams if s.get("codec_type") == "video"), None)

    print("\n" + "=" * 62)
    print(f"ФАЙЛ: {path}")
    print("=" * 62)

    if v is None:
        print("  Нет видеопотока?!")
        return 0

    w = int(v.get("width") or 0)
    h = int(v.get("height") or 0)
    pix = w * h

    r_fps = rate(v.get("r_frame_rate", "0/0"))
    avg_fps = rate(v.get("avg_frame_rate", "0/0"))
    fps = avg_fps if avg_fps > 0 else r_fps

    dur = float(fmt.get("duration") or v.get("duration") or 0)
    size_b = float(fmt.get("size") or 0)
    vbit = float(v.get("bit_rate") or 0)
    cbit = float(fmt.get("bit_rate") or 0)
    bitrate = vbit if vbit > 0 else cbit
    bpp = (bitrate / (pix * fps)) if (pix and fps) else 0.0

    codec = v.get("codec_name", "?")
    profile = v.get("profile", "?")
    pix_fmt = v.get("pix_fmt", "?")
    cspace = v.get("color_space") or "?"
    crange = v.get("color_range") or "?"
    cprim = v.get("color_primaries") or "?"
    ctrc = v.get("color_transfer") or "?"
    nb = v.get("nb_frames", "?")

    kbit_per_frame = (bitrate / fps / 8 / 1024) if fps else 0.0

    print(f"  Кодек            : {codec} ({profile})")
    print(f"  Разрешение       : {w}x{h}  ({pix / 1e6:.2f} Мпикс)")
    print(f"  FPS              : avg={avg_fps:.3f}  r={r_fps:.3f}")
    print(f"  Пиксельный формат: {pix_fmt}")
    print(f"  Цвет             : space={cspace}  range={crange}  primaries={cprim}  transfer={ctrc}")
    print(f"  Кадров / время   : {nb} / {dur:.2f} c")
    print(f"  Размер файла     : {size_b / 2 ** 30:.2f} ГиБ")
    print(f"  Битрейт (видео)  : {bitrate / 1e6:.1f} Мбит/с")
    print(f"  bpp              : {bpp:.3f} бит/пиксель")
    print(f"  На кадр          : {kbit_per_frame:.1f} КиБ")

    print("\n" + "=" * 62)
    print("ВЕРДИКТ")
    print("=" * 62)

    problems = []
    notes = []

    if fps == 0:
        problems.append("Не удалось определить fps — файл битый или это не видео.")
    else:
        if r_fps > 0 and abs(r_fps - avg_fps) > 0.05:
            problems.append(
                f"Похоже на VFR (avg={avg_fps:.3f} vs r={r_fps:.3f}). "
                "В Premiere будут рывки — перегони в CFR: scripts/master-encode.sh"
            )
        if fps < 50:
            problems.append(f"fps={fps:.1f}: для геймплея дёргано. Пиши/экспортируй 60.")
        elif abs(fps - 59.94) < 0.02:
            notes.append("FPS 59.94: для YouTube лучше 60.000." )

    if bpp and bpp < 0.10:
        problems.append(f"bpp={bpp:.3f}: почти гарантированная «каша». Нужен битрейт в 2–4 раза выше.")
    elif bpp and bpp < 0.20:
        problems.append(f"bpp={bpp:.3f}: на грани. Цель: >= 0.20 для финала, >= 0.50 для записи.")

    if crange in ("pc", "full", "jpeg"):
        problems.append("color_range=full/pc: в SDR-пайплайне YouTube это даёт «выцветшую» картинку. Нужен Limited (tv).")

    if cspace not in ("bt709", "unknown", "?"):
        # для HD/SDR ожидаем bt709
        if pix >= 1280 * 720:
            problems.append(f"color_space={cspace}: для SDR нужен bt709.")

    if crange in ("unknown", "?") or cspace in ("unknown", "?"):
        notes.append("Цветовые метаданные не прописаны: Premiere может угадать неверно (серый/выцветший вид).")

    if pix_fmt and "10" not in pix_fmt and codec in ("hevc", "av1"):
        notes.append("Для HEVC/AV1 на градиентах лучше 10 бит (yuv420p10le / P010).")

    if not problems:
        print("  ✅ Критичных проблем нет: CFR, цвет и битрейт в норме.")
    for p in problems:
        print(f"  ⚠ {p}")
    for n in notes:
        print(f"  · {n}")
    print()
    return 0


if __name__ == "__main__":
    sys.exit(main())
