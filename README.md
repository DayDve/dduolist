# dduolist — группируемые списки фильтров uBlock Origin

Автообновляемые списки фильтров для [uBlock Origin](https://github.com/gorhill/uBlock).
Импортируешь **один** URL — а группы добавляешь простым созданием папки в репозитории.

## Быстрый старт

В uBlock Origin (Панель управления → Списки сторонних фильтров → Импорт) добавь:

```
https://daydve.github.io/dduolist/filters.txt
```

## Как это работает

Содержимое `dist/filters.txt` — это главный список с директивами `!#include` на подправлены:

```
! Title: My uBlock Filter Groups
! Expires: 1 days
!#include kinobox-mirrors.txt
!#include my-static.txt
```

uBlock Origin сам подтягивает `!#include`-подправлены из того же каталога на GitHub Pages.
**Ты импортируешь один URL, а все группы приходят автоматически** — добавлять новые группы
в uBlock на каждом устройстве не нужно.

Сборку выполняет GitHub Actions по cron (каждые 6 часов) и при ручном запуске, публикуя `dist/` в GitHub Pages.

## Структура

```
groups/
  _lib/common.sh          общие функции (source)
  <group>/handler.sh      обработчик группы (обязателен)
  <group>/config.sh       параметры группы (необязателен, source внутри handler)
  <group>/template.txt    шаблон группы
build.sh                  сборщик: groups/* -> dist/
dist/
  filters.txt             главный список (!#include на группы)
  <group>.txt             подправлен каждой группы
```

## Контракт обработчика группы

Обработчик `handler.sh` вызывается как:

```bash
GROUP_NAME=<имя> GROUP_DIR=<путь к папке группы> bash groups/<имя>/handler.sh
```

**Что должен делать:** вывести на stdout готовый список фильтров этой группы.
Всё остальное (создание папок, `!#include`, метаданные) делает `build.sh`.

## Добавление группы

1. Создай папку `groups/<имя>/`.
2. Положи туда `template.txt` (шаблон) и `handler.sh` (обработчик).
3. Обработчик считывает свои параметры через `source config.sh` (если нужно)
   или напрямую из окружения `$GROUP_DIR`.

Готово. При следующем запуске collection группа появится в `dist/`, и uBlock подтянет её сам.

### Пример: статичная группа (заглушка-обработчик)

`groups/my-static/handler.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/../_lib/common.sh"
dump_template
```

`groups/my-static/template.txt`:

```
! Скрыть боковую панель
example.com##aside.sidebar
```

### Пример: динамическая группа (актуальный список доменов)

`groups/kinobox-mirrors/config.sh`:

```bash
export REDIRECT_URL="https://kinokino.vip/film/12930515/"
export KNOWN_DOMAINS="fbfind.top,fbfree.cfd,fbsite.top"
export DOMAINS_PLACEHOLDER="__DOMAINS__"
```

`groups/kinobox-mirrors/handler.sh` — берёт известные домены, догружает текущий
из редиректа `REDIRECT_URL`, подставляет в `template.txt` вместо `__DOMAINS__`.

## Локальный запуск

```bash
./build.sh        # соберёт dist/ из groups/
```

## Примечания

- `!#include` резолвит подправлены относительно расположения главного списка,
  поэтому все `.txt` лежат плоско в одном каталоге `dist/`.
- Группа без `handler.sh` пропускается при сборке (ошибка в логе).
- Ошибка в любом обработчике прервёт сборку (`set -e`), деплой не произойдёт
  — так плохая группа не положит весь список.
