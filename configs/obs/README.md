# Профиль OBS: как импортировать и что внутри

OBS хранит профили здесь (Windows):

```
%APPDATA%\obs-studio\basic\profiles\<ИмяПрофиля>\
    basic.ini
    recordEncoder.json
```

## Вариант 1 — импорт папкой (быстро)

1. Закрой OBS.
2. Создай папку `%APPDATA%\obs-studio\basic\profiles\Minecraft 4K AV1\`.
3. Скопируй туда `basic.ini` и `recordEncoder.json` из этой папки.
4. Запусти OBS → `Профиль → Minecraft 4K AV1`.
5. **Проверь в GUI** `Настройки → Вывод → Запись`, что кодер = `NVIDIA NVENC AV1`, CQP 18,
   пресет P7, multipass fullres, look-ahead ON, psycho visual tuning ON.
6. **Проверь** `Настройки → Видео`: база/выход 2560×1440 (или 3840×2160), FPS 60.
7. **Проверь** `Настройки → Дополнительно`: цветовой формат `P010`, пространство `Rec. 709`,
   диапазон `Ограниченный`.

> Ключи в `basic.ini`/`recordEncoder.json` зависят от версии OBS. Если какая-то настройка не подхватилась —
> просто выставь её руками по таблице ниже: значения те же, времязатраты — минута.

## Вариант 2 — всё руками (если импорт капризничает)

`Настройки → Вывод → Расширенный → Запись`:

| Параметр | Значение |
|---|---|
| Формат | MKV |
| Кодер | NVIDIA NVENC AV1 |
| Управление битрейтом | CQP |
| CQ Level | 18 (мастер: 16) |
| Пресет | P7 (Slowest / Max Quality) |
| Tuning | High Quality |
| Multipass | Two Passes (Full Resolution) |
| Профиль | main |
| Look-ahead | ON |
| Psycho Visual Tuning | ON |
| B-frames | 3 |
| Split Encode | Auto |
| Repeat Headers | OFF |

`Настройки → Видео`: база = выход = 2560×1440 (или 3840×2160), FPS = 60 (или 120), фильтр = Lanczos.

`Настройки → Дополнительно`: P010, Rec. 709, Ограниченный (Limited), 48 кГц, Стерео.
`Настройки → Дополнительно → Приоритет процесса`: Выше обычного. Запуск от админа: ON.

## Файлы

| Файл | Что это |
|---|---|
| `basic.ini` | основной профиль: видео, аудио, расширенный вывод, путь записи |
| `recordEncoder.json` | настройки кодера AV1 NVENC для вкладки «Запись» |

## Что поменять под себя обязательно

- `RecFilePath` в `basic.ini` → свой NVMe-диск (сейчас там `D:/Records`).
- `BaseCX/BaseCY/OutputCX/OutputCY` → под свой монитор (1440p или 4K через DSR).
- `FPSCommon` → 60 или 120.
- Если у тебя не RTX 40/50 — замени кодер на `obs_nvenc_hevc_tex` (HEVC) и оставь CQP 18.
