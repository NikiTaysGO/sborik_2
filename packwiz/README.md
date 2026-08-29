# Packwiz-пак: Minecraft 26.2 / Forge 65.1.0

Один пак — одна ссылка — работает и для клиента, и для сервера.

19 из 22 модов ставятся напрямую с CurseForge (packwiz хранит только id проекта/файла — сами jar
в репозитории не лежат). Три мода отключили у себя на CurseForge доступ для сторонних приложений
(EssentialHomes, Wolf Saddle-Bag, Veinminer Enchantment) — их jar-файлы лежат прямо в `mods/` и
раздаются из этого же репозитория.

## 1. Запушить на GitHub

Репозиторий должен быть **публичным** (иначе `raw.githubusercontent.com` не отдаст файлы без токена).

```bash
cd /Users/supremes/minecraft_server_s
git init
git add packwiz/ docker-compose.yml .env.example
git commit -m "packwiz modpack"
git remote add origin https://github.com/<owner>/<repo>.git
git branch -M main
git push -u origin main
```

## 2. Подставить реальный URL

После пуша выполни (один раз, из этой папки):

```bash
./configure.sh <owner> <repo> [branch] [path-in-repo]
# пример, если пушил весь minecraft_server_s в ветку main:
./configure.sh nikitays0987 mc-server main packwiz
# пример, если packwiz/ — корень отдельного репозитория:
./configure.sh nikitays0987 mc-modpack main
```

Скрипт подставит реальный `raw.githubusercontent.com` URL в три самохостящихся мода
(`essential-homes.pw.toml`, `wolf-saddle-bag.pw.toml`, `veinminer-enchantment.pw.toml`) и
пересчитает хэши в `index.toml`/`pack.toml`. Остальные 19 модов URL не трогает — они и так
указывают на CurseForge.

В конце выведет **итоговую ссылку на pack.toml** — это и есть та самая единая ссылка.

Закоммить и запушь результат:

```bash
git add packwiz/
git commit -m "configure pack urls"
git push
```

## 3. Сервер

Впиши итоговую ссылку в `.env` рядом с `docker-compose.yml`:

```
PACKWIZ_URL=https://raw.githubusercontent.com/<owner>/<repo>/<branch>/packwiz/pack.toml
```

`docker compose up -d` — при старте контейнер сам скачает все моды по ссылке (itzg/minecraft-server
поддерживает packwiz из коробки, проверено локальным тестом — сервер поднимается за ~12 секунд).

## 4. Клиент

**Prism Launcher** (рекомендуется): Add Instance → Import → вставить ту же ссылку на `pack.toml`. Лаунчер сам поставит нужный Forge и моды, и будет обновлять их при каждом запуске.

**Любой другой лаунчер**: скачать [packwiz-installer-bootstrap.jar](https://github.com/packwiz/packwiz-installer-bootstrap/releases), положить в папку инстанса и запустить:

```bash
java -jar packwiz-installer-bootstrap.jar https://raw.githubusercontent.com/<owner>/<repo>/<branch>/packwiz/pack.toml
```

Forge 65.1.0 для Minecraft 26.2 в этом случае нужно поставить отдельно официальным Forge-инсталлятором (packwiz-installer сам ставит только моды, не сам лоадер) — в Prism это делает сам лаунчер, вручную не нужно.

## Клиентские моды

`InventoryProfilesNext`, `libIPN`, `Xaero's Minimap`, `Xaero's World Map` помечены `side = "client"` —
сервер их не скачивает (проверено: в тесте сервер получил только 18 из 22 модов, ровно те, что не
клиентские).

## Обновление модов

- Мод с CurseForge: `packwiz curseforge add --addon-id <id>` (или обновить конкретный: `packwiz update <slug>`, все разом — `packwiz update --all`).
- Самохостящийся мод: положить новый jar в `mods/`, поправить `.pw.toml` вручную (или пересоздать по образцу существующих), запустить `packwiz refresh`.

После любого изменения — закоммить и запушить. Ссылка не меняется, клиенты и сервер подхватят
изменения при следующем запуске автоматически.
