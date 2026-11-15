# Моды для Minecraft 1.21.11 (Fabric) — таблица для копирования

Версии проверены в ноябре 2026 под **1.21.11**. Ссылки ведут на проекты Modrinth
(в Prism Launcher / Modrinth App можно ставить прямо оттуда — они сами подберут версию).

Формат: `Мод — версия — зачем`.

## Ядро (ставить обязательно)

| Мод | Версия | Ссылка | Зачем |
|---|---|---|---|
| Fabric API | `0.141.6+1.21.11` | modrinth.com/mod/fabric-api | база |
| Sodium | `mc1.21.11-0.8.14` | modrinth.com/mod/sodium | рендер-движок, +fps, стабильный frame time |
| Lithium | `mc1.21.11-0.21.4` | modrinth.com/mod/lithium | логика игры |
| FerriteCore | `8.2.0` | modrinth.com/mod/ferrite-core | память |
| ModernFix | `5.26.3` | modrinth.com/mod/modernfix-mvus | фиксы/загрузка |
| Krypton | `0.2.10` | modrinth.com/mod/krypton | сеть (PvP) |
| ImmediatelyFast | `1.14.3+1.21.11` | modrinth.com/mod/immediatelyfast | HUD/текст |
| Entity Culling | `1.11.3` | modrinth.com/mod/entityculling | отсечение сущностей |
| ScalableLux | `0.1.6` | modrinth.com/mod/scalablelux | освещение |
| Gnetum | `4.6.3` | modrinth.com/mod/gnetum | HUD реже = +fps |
| Ixeris | `4.6.8` | modrinth.com/mod/ixeris | меньше input lag |
| Tick Sync | `1.4.0` | modrinth.com/mod/tick-sync | позиции игроков раньше |
| Bobby | `5.2.11.1` | modrinth.com/mod/bobby | дальность обзора из кэша |

## Качество картинки

| Мод | Версия | Ссылка | Зачем |
|---|---|---|---|
| Sodium Extra | `mc1.21.11-0.9.4` | modrinth.com/mod/sodium-extra | мипмапы, AF, погода, туман |
| Reese's Sodium Options | `mc1.21.11-2.2.4` | modrinth.com/mod/reeses-sodium-options | меню Sodium |
| Fullscreen Tweaks | `2.0.2` | modrinth.com/mod/fullscreen-tweaks | borderless + OBS |
| Flashback | `0.39.10` | modrinth.com/mod/flashback | реплеи → рендер 4К/120 |
| Fabrishot | актуальная | modrinth.com/mod/fabrishot | 4К-скриншоты для превью |
| Zoomify | `2.15.2` | modrinth.com/mod/zoomify | зум |
| BetterF3 | `17.0.0` | modrinth.com/mod/betterf3 | читаемый F3 |

## PvP (легально)

| Мод | Версия | Ссылка | Зачем |
|---|---|---|---|
| BactroMod | `3.5` | modrinth.com/mod/bactromod | яркость, fog, fire/shield offset, без тыквы |
| BetterHurtCam | `1.12.0` | modrinth.com/mod/betterhurtcam | hurtcam off/old |
| Armor Hud | `0.9` | modrinth.com/mod/armor-hud-by-mcjunky33 | броня |
| AppleSkin | `3.0.8` | modrinth.com/mod/appleskin | сатурация |
| PartialHearts | `1.1.1` | modrinth.com/mod/partialhearts | точное HP |
| HitColor X | `1.1.0` | modrinth.com/mod/hitcolorx | цвет урона |
| Effect Timer Plus | `2.2.7` | modrinth.com/mod/effecttimerplus | таймеры |
| Tiers | `0.8.4` | modrinth.com/mod/tiers | ранг в нике |
| Shield Fixes | `2.0.4` | modrinth.com/mod/complete-shield-fixes | щит |
| Combat Hitboxes | `1.0.10` | modrinth.com/mod/combat-hitboxes | хитбоксы |
| Crosshair Addons | `2.1.0` | modrinth.com/mod/crosshair-addons-public | прицел |
| Advanced Mouse Sensitivity | `1.0.1` | modrinth.com/mod/advanced-mouse-sensitivity | X/Y сенса |
| Marlow's Crystal Optimizer | `2.0.0` | modrinth.com/mod/marlow-crystal-optimizer | CPvP |
| Hero's Anchor Optimizer | `1.1.4` | modrinth.com/mod/hero-anchor-optimizer | CPvP |
| Mod Menu | `17.0.1` | modrinth.com/mod/modmenu | настройки модов |
| ViaFabricPlus | `4.4.15` | modrinth.com/mod/viafabricplus | серверы других версий |

## Опционально

| Мод | Версия | Зачем | Когда НЕ ставить |
|---|---|---|---|
| Iris Shaders | `1.10.8+1.21.11` | шейдеры для «кино» | в PvP и вместе с VulkanMod |
| VulkanMod | под 1.21.11 | рендер Vulkan | если используешь Sodium-моды/шейдеры |
| Salt's Anti-Aliasing | `1.1` | MSAA/SSAA/TAA/DLAA | без VulkanMod не работает (1.21.9–1.21.11) |
| Simple Voice Chat | `2.6.22` | тимплей | если не нужен голос |
| Disable Lighting | `1.0.0` | fullbright + fps | на запись (убивает атмосферу) |
| Xaero's Minimap / World Map | актуальные | навигация | на записи (видно в кадре) |

## Стоп-лист (бан + репутация)

ESP, SilentAim, Triggerbot, Reach, AutoTotem, KillAura, Fly, X-Ray, «ghost-клиенты».
Ничего из этого в гайде нет и ставить нельзя — PvP-серверы и античиты это ловят, а аудитория видит.

## Как проверить, что версии совпали

1. Prism → инстанс → `Mods` → фильтр `1.21.11`.
2. Запусти игру, выйди, открой `logs/latest.log`: не должно быть `Mixin apply failed` / `NoSuchMethodError`.
3. F3 → fps и «C:» (chunk updates) — стабильность важнее пиковых значений.
