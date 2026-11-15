# Topaz Video AI: пресеты под Minecraft

Проверено на модели 2026 года: Proteus, Rhea / Rhea XL, Gaia, Nyx, Starlight (Cloud / Mini), Astra.
Для Minecraft (чистая CG-графика, резкие края) действует правило: **минимум обработки, максимум точности**.

## Базовый пресет: 1440p60 → 4K60 (Proteus)

| Параметр | Значение |
|---|---|
| Model | Proteus |
| Mode | Manual (сначала нажми `Auto/Estimate`, потом правь) |
| Upscale | 1.5×–2× до 3840×2160 |
| Revert Compression | 15–25 |
| Recover Detail | 30–45 |
| Sharpen | 0–8 |
| Reduce Noise | 0 |
| Dehalo | 0–5 |
| Anti-alias / Deblur | 0 |
| Add Noise | 0 |
| Frame rate | Keep original (60) |
| Output codec | HEVC Main10, 60–90 Мбит/с (или ProRes 422 HQ) |
| Output color | Rec.709 / Limited |

## Альтернатива: Rhea XL (максимум текстуры)

| Параметр | Значение |
|---|---|
| Model | Rhea XL |
| Upscale | 2× |
| Sharpen | 0 |
| Recover Detail | 40 |
| Output | HEVC Main10 / ProRes |

Сравни с Proteus на одном кадре (`Compare`): Rhea может «дорисовать» лишнее на блоках и тексте HUD.

## Альтернатива: Gaia HQ (CG/анимация)

Хорошо держит чистые линии и плашки цвета, меньше «синтетики» на дальних планах.
Ставь, если Proteus/Minecraft-текстуры выглядят слегка «пластиковыми».

## Когда какой

| Ситуация | Модель |
|---|---|
| Чистая запись 1440p/4K, всё хорошо | **Proteus** (или Gaia HQ) |
| Нужно максимум деталей, готов сравнивать | Rhea XL |
| Старая запись с артефактами сжатия | Proteus (Revert Compression 40–60) или Artemis |
| Сильный шум/тёмная сцена | Nyx (осторожно) |
| Совсем убитый материал (360p, VHS) | Starlight Mini / Cloud |

## Чего не делать

- Не включай денойз на чистом материале.
- Не шарпи больше 8: на блоках появятся ореолы («звон»).
- Не апскейль дважды и не апскейль уже сжатый YouTube-файл.
- Не интерполируй 60→120 для YouTube (плеер всё равно отдаст 60).
- Не выводи H.264 8 бит на финал: бандинг на небе вернётся.

## Скорость (ориентир)

| GPU | 1440p→4K, 1 мин 60 fps | Время |
|---|---|---|
| RTX 4070 Ti | Proteus 2× | ~4–6 мин |
| RTX 4090 | Proteus 2× | ~2–3 мин |

На длинные видео ставь `Process → Export All` и оставляй на ночь.
