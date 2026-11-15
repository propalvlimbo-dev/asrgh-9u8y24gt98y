# NVIDIA: настройки драйвера под Minecraft (AA + стабильность)

Путь: **NVIDIA App → Graphics → Minecraft (javaw.exe)** или
**Панель управления NVIDIA → Управление параметрами 3D → Программа: javaw.exe**.

Важно: применяй настройки именно к **`javaw.exe`** (Java), потому что Minecraft — это Java-приложение,
а не отдельный exe.

## Основной профиль: «Запись 1440p/4K + сглаживание»

| Параметр | Значение | Зачем |
|---|---|---|
| DSR — Factors | **2.25x** (и 1.78x как эконом) | суперсэмплинг: рендер в 4К на 1440p-мониторе |
| DSR — Smoothness | **15%** | 0% — резко, но с артефактами; 33% — мыло |
| DLDSR (RTX 20+) | **2.25x DLDSR** | ИИ-даунскейл: качество SSAA при меньшей нагрузке |
| Antialiasing — Mode | `Application-controlled` | Override в OpenGL почти не работает |
| Antialiasing — FXAA | **Off** | мылит текст и HUD |
| Antialiasing — Gamma correction | Off | |
| Anisotropic filtering | **16x** | резкие текстуры под углом (или включи AF в Sodium Extra — тогда `Application-controlled`) |
| Texture filtering — Quality | **High quality** | |
| Texture filtering — Negative LOD bias | **Allow** | чтобы AF не «замыливал» |
| Power management mode | **Prefer maximum performance** | нет просадок из-за троттлинга |
| Low Latency Mode | `On` (PvP-профиль: `Ultra`) | Ultra иногда даёт рваный pacing в OBS |
| Max frame rate | **240** (или 300) | ровнее, чем Unlimited |
| Vertical sync | **Off** | VSync = input lag |
| Threaded optimization | Auto | |
| Shader cache size | 10 GB | меньше статтеров при компиляции |
| Vulkan/OpenGL present method | Auto (или `Prefer layered on DXGI swapchain`, если OBS не видит окно) | |

## PvP-профиль (отдельный, если хочешь максимум отклика)

| Параметр | Значение |
|---|---|
| DSR | **Off** (максимум fps) |
| Low Latency Mode | **Ultra** |
| Power management | Prefer maximum performance |
| Max frame rate | **Off** (или 400) |
| Texture filtering Quality | High performance |
| Anisotropic | Application-controlled |

Переключай профили в NVIDIA App: `Minecraft (Recording)` и `Minecraft (PvP)`.

## Windows: что проверить

| Настройка | Значение |
|---|---|
| Параметры экрана → Дополнительно → Частота обновления | **максимум** (144/165/240), не 60 |
| Параметры экрана → Масштаб | 100% (иначе OBS/записи могут «плыть» по размеру окна) |
| Игры → Game Mode | **On** |
| Игры → Xbox Game Bar | **Off** (DVR пишет 30 fps и ест fps) |
| Игры → Захваты (Captures) | Off |
| Графика → Изменение настроек графики по умолчанию → HAGS | **On** (аппаратное планирование GPU) |
| Графика → Оптимизации для оконных игр | **On** |
| Электропитание | Схема «Максимальная производительность» |
| Полноэкранная оптимизация для javaw.exe | **Off** (правый клик по exe → Свойства → Совместимость) |

## Как проверить, что DSR реально включился

1. `Параметры экрана → Разрешение`: должно появиться `3840×2160 (DSR)` (или 3413×1920).
2. В игре `F3`: строка `Display: 3840x2160` (или сколько выбрал).
3. Сделай зум на диагональный забор: края гладкие, без ступенек.

## Чего не делать

- Не включай **FXAA** «для сглаживания»: получишь мыло вместо AA.
- Не включай **Override** для AA: Minecraft не поддерживает запрошенный формат, эффекта не будет.
- Не ставь **DSR Smoothness 50%+**: картинка станет мягкой, и ты снова получишь «мыло».
- Не включай **G-Sync + VSync** одновременно с записью: испортишь frame pacing в OBS.
