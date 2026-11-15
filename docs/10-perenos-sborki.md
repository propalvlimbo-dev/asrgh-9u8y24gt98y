# 10. Перенос сборки в другой лаунчер (Modrinth App, официальный, ATLauncher, MultiMC)

Сборка — это **не привязка к Prism**. Внутри неё только `.jar`-моды и текстовые конфиги,
поэтому переносится в любой лаунчер за 2 минуты. Единственное требование — **Minecraft Java 1.21.11 + Fabric**
и **Microsoft-аккаунт с лицензией** (его требуют все лаунчеры, это не особенность Prism).

---

## Что именно переносится

| Что | Где лежит в Prism | Куда копировать |
|---|---|---|
| Моды | `...\instances\PvP Clean 1.21.11\minecraft\mods\*.jar` | папка `mods` нового инстанса |
| Настройки игры | `...\minecraft\options.txt` | корень инстанса (рядом с `mods`) |
| Конфиги модов | `...\minecraft\config\` | папка `config` нового инстанса |
| Ресурспаки (если ставил) | `...\minecraft\resourcepacks\` | папка `resourcepacks` |

Всё остальное (Minecraft, Fabric Loader, Java) каждый лаунчер скачает сам.

---

## Modrinth App (самый простой после Prism)

1. Modrinth App → **Create profile** → Minecraft **1.21.11** → **Fabric**.
2. В профиле: значок папки → **Open folder**.
3. Скопируй туда `mods`, `config`, `options.txt` из Prism-инстанса.
4. Launch.

## Официальный лаунчер (Mojang/Microsoft)

1. Поставь Fabric: `fabricmc.net/use/installer` → выбери **1.21.11** → Install.
2. Открой `%APPDATA%\.minecraft`.
3. Скопируй `mods`, `config` в `.minecraft`, `options.txt` — тоже в `.minecraft`
   (старый `options.txt` сохрани как `.bak`).
4. В официальном лаунчере выбери профиль `fabric-loader-1.21.11`.

## ATLauncher / MultiMC / любой другой

Схема одинаковая: создать инстанс `1.21.11 + Fabric` → открыть его папку → скопировать `mods`, `config`, `options.txt`.

## Linux / macOS

```bash
# Prism
~/.local/share/PrismLauncher/instances/"PvP Clean 1.21.11"/minecraft/
# Modrinth App
~/.local/share/ModrinthApp/profiles/<имя профиля>/
# официальный лаунчер
~/.minecraft/
```

---

## Проверка после переноса

1. Запусти игру → **Mods → Mod Menu**: должно быть ~20 модов (Sodium, Lithium, HitColor X, BactroMod и т.д.).
2. `F3`: версия `1.21.11`, в правом верхнем углу — `Fabric`.
3. Если модов меньше — значит часть `.jar` не скопировалась (проверь, что копировал **файлы**, а не папку `mods` внутрь `mods`).
4. Если игра не стартует — почти всегда либо не тот Fabric/версия, либо Java не 21.

---

## Чего перенос **не** решает

- **Лицензию.** Вход в аккаунт Microsoft обязателен в Prism, Modrinth App, ATLauncher, официальном лаунчере.
  Смена лаунчера не меняет требование лицензии.
- **Онлайн на серверах.** PvP-серверы пускают только лицензионные аккаунты (античиты + вход по Microsoft).
- **Настройки драйвера и OBS.** DSR/DLDSR, NVENC и профили OBS живут вне лаунчера — их настраиваешь один раз в системе.
