# Premiere Pro / After Effects: шпаргалка экспорта

## 1. Секвенция

| Параметр | Значение |
|---|---|
| Разрешение | как запись (2560×1440 или 3840×2160) |
| FPS | **60.000** (не 59.94) |
| Пиксели | Square Pixels 1.0 |
| Поля | No Fields (Progressive) |
| Цвет | Rec. 709 |
| Аудио | 48 000 Гц, Stereo |

## 2. Мастер-экспорт (архив / для Topaz)

| Параметр | Значение |
|---|---|
| Format | QuickTime |
| Codec | **Apple ProRes 422 HQ** (или DNxHR HQX) |
| Битовая глубина | 10 бит |
| Render at Maximum Depth | **ON** |
| Use Maximum Render Quality | **ON** |
| Audio | PCM 48 кГц 24 бит |

## 3. YouTube H.264 (максимальная совместимость)

| Параметр | 1440p60 | 2160p60 |
|---|---|---|
| Format | H.264 | H.264 |
| Profile / Level | High / 5.1 | High / 5.2 |
| Bitrate | VBR 2 pass | VBR 2 pass |
| Target | 45 Мбит/с | 70–90 Мбит/с |
| Max | 60 Мбит/с | 110 Мбит/с |
| Keyframe distance | 2 сек (120 кдр) | 2 сек |
| Render at Maximum Depth | ON | ON |
| Use Maximum Render Quality | ON | ON |
| Audio | AAC 320 кбит/с | AAC 320–384 кбит/с |
| Color | Rec.709, Limited | то же |

## 4. YouTube HEVC 10 бит (компактнее)

| Параметр | Значение |
|---|---|
| Format | HEVC (H.265) |
| Profile | **Main10** |
| Bitrate | VBR 2 pass, 50–70 Мбит/с (4К60) |
| Chroma | 4:2:0 10 бит |
| Color | Rec.709, Limited |

## 5. Через Voukoder / AfterCodecs (если нужен CRF/AV1)

| Кодек | CRF/CQ | Пресет | Комментарий |
|---|---|---|---|
| x265 10 бит | **CRF 17–19** | slow | лучший «качество/размер» |
| SVT-AV1 | **CRF 20–22** | preset 5–6 | лучшее сжатие, но медленно |
| NVENC AV1 | CQ 20–24 | P7 | быстро, почти так же хорошо |
| NVENC HEVC | CQ 19–21 | P7 | быстрая альтернатива |

## 6. Чего не делать

| Нельзя | Почему |
|---|---|
| Optical Flow на геймплее | «желе», артефакты на HUD |
| Frame Blending | призрачные кадры |
| Апскейл в таймлайне (Set to Frame Size вверх) | мыло вместо деталей |
| Экспорт H.264 из After Effects | слабый энкодер, лишний проход |
| Пресет «Match Source — Adaptive High» | низкий битрейт, «каша» |
| «Use Previews» | подставит недожатые превью |
| Смена разрешения секвенции после монтажа | пересчёт трансформаций |

## 7. After Effects (только графика)

| Задача | Настройка |
|---|---|
| Титры/плашки | композиция = разрешение секвенции, 60 fps |
| Рендер с альфой | ProRes 4444 |
| Рендер без альфы | ProRes 422 HQ, 10 бит |
| H.264 | **не из AE**, а через Media Encoder с пресетом из §3 |

## 8. Проверка после экспорта

```bash
bash scripts/qc-check.sh final.mp4
```

Ожидаемо: `fps=60.000`, `color_range=tv`, битрейт ≥ целевого, `pix_fmt=yuv420p` или `yuv420p10le`,
длительность совпадает с таймлайном.
