# Сборка «PvP Clean 1.21.11» — установка в один клик

Твой запрос был: **на экране только hitcolor, маленький щит, без тряски камеры, без частиц,
минимум задержек, максимум оптимизации и идеальная картинка**. Вот эта сборка — 20 модов, ничего лишнего,
никаких HUD-панелей, миникарт, таймеров и брони поверх экрана.

---

## Как поставить (2 минуты)

### Вариант 1 — Prism Launcher (рекомендую)

1. Скачай папку `pack-clean` целиком (или только `install.bat` + `install.ps1` — они должны лежать рядом).
2. Запусти **`install.bat`** (двойной клик).
3. Открой **Prism Launcher** → появится инстанс **`PvP Clean 1.21.11`** → запускай.
   Первый запуск скачает сам Minecraft и Fabric Loader.
4. В игре открой **Mod Menu** и пройди 6 пунктов из `PVP-CLEAN-READ-ME.txt`
   (лежит в папке инстанса, там же список модов).

Если Prism установлен не в `%APPDATA%\PrismLauncher`, запусти из PowerShell:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1 -PrismInstances "D:\PrismLauncher\instances"
```

### Вариант 2 — моды в уже существующий инстанс

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1 -ModsOnly -ModsPath "C:\...\instance\minecraft\mods"
```

### Вариант 3 — Linux/macOS

```bash
./install.sh -d ~/.local/share/PrismLauncher/instances/"PvP Clean 1.21.11"/minecraft/mods
```

### Дополнительно

```powershell
# + Flashback (запись реплеев и рендер клипов в 4K/120, ~200 МБ)
powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1 -WithFlashback
```

Установщик качает **актуальные версии модов с Modrinth** под `1.21.11 + Fabric` — поэтому он не устареет,
когда моды обновятся. Если какой-то мод ещё не портирован на 1.21.11, он честно напишет `пропущен`
и не сломает остальное.

---

## Что внутри

| Блок | Моды | Зачем |
|---|---|---|
| **Оптимизация** | Sodium, Lithium, FerriteCore, ModernFix, ImmediatelyFast, Entity Culling, ScalableLux | +100–300% fps, ровный frame time, меньше статтеров |
| **Задержка** | Ixeris, Tick Sync, Krypton | ввод вне рендер-потока, позиции игроков раньше, сеть без лага пакетов |
| **Чистый экран** | HitColor X, BetterHurtCam, BactroMod, Custom Shield Scale | **только цвет вспышки урона**, без тряски камеры, маленький щит, без огня/тыквы/тумана |
| **Картинка** | Sodium Extra, Reese's Sodium Options | мипмапы 4x, AF 16x, облака, частицы, туман — всё, что нужно для чистых краёв |
| **Удобство** | Fullscreen Tweaks, Mod Menu, Zoomify | borderless для OBS, настройки, зум для проверки сглаживания |

Полный разбор каждого мода и того, что **специально не включено** — в [`modlist.md`](modlist.md).
Точные настройки в игре — в [`settings.md`](settings.md).

---

## Что нужно донастроить руками (3 минуты, обязательно)

| Где | Что | Значение |
|---|---|---|
| Mod Menu → BactroMod | Brightness Boost | 15 |
| Mod Menu → BactroMod | Pumpkin Blur | OFF |
| Mod Menu → BactroMod | Fire Offset | −100 |
| Mod Menu → BactroMod | Shield Offset | −30 |
| Mod Menu → BactroMod | Fog | OFF |
| Mod Menu → BetterHurtCam | Hurtcam Enabled | **OFF** |
| Mod Menu → Custom Shield Scale | Scale / Height | 0.5 / −10 |
| Mod Menu → HitColor X | цвет вспышки | белый или красный |
| Options → Accessibility | Camera Bobbing / Hand Bobbing | 0% / 40% |
| Video → Particles | уже Minimal (из options.txt) | — |
| Sodium Extra | Mipmap / Anisotropic | 4x / 16x |
| NVIDIA | DSR/DLDSR 2.25x, Smoothness 15% | сглаживание без шейдеров |

`options.txt` установщик уже подложил (частицы минимальные, VSync off, 240 fps, FOV-эффекты off).
Старый файл сохраняется как `options.txt.bak`.

---

## Идеальная картинка: что делает сборка и что делать тебе

1. **Сглаживание** — не модами, а драйвером: DSR/DLDSR `2.25x` (1440p → рендер в 4К).
   Это SSAA, лучший вид AA, и он не конфликтует ни с одним модом сборки.
2. **Мипмапы 4x + AF 16x** — убирают мерцание и «мыло» на дальних текстурах.
3. **Частицы Minimal** — меньше визуального шума, и кодеру легче (меньше артефактов).
4. **Без шейдеров** — как ты и просил: сборка вообще не содержит Iris, чтобы ничего не мешало PvP.
5. Запись: OBS + NVENC AV1, CQP 16–18, 10 бит, 60 fps — см. `../docs/05-obs.md`.

---

## Если что-то пошло не так

| Симптом | Что делать |
|---|---|
| «Скрипты PowerShell отключены» | запускай через `install.bat` (он сам ставит `-ExecutionPolicy Bypass`) |
| Инстанс не появился в Prism | Prism в другой папке → параметр `-PrismInstances`; или `-ModsOnly` в существующий |
| Мод «пропущен» | ещё не портирован на 1.21.11 — скачай вручную с modrinth.com или подожди |
| Краш на старте | проверь, что игра точно **1.21.11 Fabric**; удали моды, которых нет в `modlist.md` |
| Нет Fabric Loader в инстансе | Prism → Edit → Mods/Version → Add Fabric Loader |
| Экран «плывёт» при беге | Options → Accessibility → Camera Bobbing 0% (и `fovEffectScale:0.0` уже в options.txt) |
| Хочу ещё меньше на экране | `F1` в игре скрывает весь HUD (hitcolor остаётся, это эффект, а не HUD) |

---

## Важно (честно)

- Все моды в сборке **клиентские и легальные**: никаких ESP, SilentAim, AutoTotem, Reach.
  Такие вещи = бан и убитый канал, их здесь нет и не будет.
- Сборка не заменяет навык: тир (LT1 и выше) набирается аимом и таймингами, а не модами.
  Сетап убирает то, что тебе мешает — остальное руками, см. `../docs/04-pvp-lt1.md`.
- Установщик качает моды с официального API Modrinth. Хочешь проверить — открой `install.ps1`,
  там видно каждый URL-запрос и список слагов.
