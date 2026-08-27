#!/usr/bin/env bash
# Сборщик групп фильтров.
#
# Структура:
#   groups/
#     _lib/common.sh        общие функции (source)
#     <group>/handler.sh    обработчик группы (обязателен, вызывается: bash handler.sh)
#     <group>/config.sh     параметры группы (необязателен, source внутри handler)
#     <group>/template.txt  шаблон группы (необязателен компонентно)
#
# Контракт обработчика: вывод на stdout = готовый список фильтров группы.
#
# Итог в dist/:
#   filters.txt             главный список с !#include на каждую группу
#   <group>.txt             подправлен каждой группы (для !#include)
#
# Любая новая папка в groups/* с handler.sh автоматически становится группой:
# добавлять её в uBlock не нужно — главный filters.txt уже подтянет.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GROUPS_DIR="$ROOT/groups"
DIST_DIR="$ROOT/dist"

rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"

shopt -s nullglob
group_dirs=("$GROUPS_DIR"/*/)
shopt -u nullglob

if [[ ${#group_dirs[@]} -eq 0 ]]; then
  echo "No groups found in $GROUPS_DIR" >&2
  exit 1
fi

cat > "$DIST_DIR/filters.txt" <<'EOF'
! Title: My uBlock Filter Groups
! Expires: 1 days
! Homepage: https://github.com/DayDve/dduolist

EOF

for group_dir in "${group_dirs[@]}"; do
  group_dir="${group_dir%/}"
  group_name="$(basename "$group_dir")"

  if [[ -d "$group_dir" && "$group_dir" != "$GROUPS_DIR/_lib" ]]; then
    echo "Processing group: $group_name" >&2

    if [[ ! -f "$group_dir/handler.sh" ]]; then
      echo "ERROR: $group_name has no handler.sh, skipping" >&2
      continue
    fi

    GROUP_NAME="$group_name" \
    GROUP_DIR="$group_dir" \
      bash "$group_dir/handler.sh" > "$DIST_DIR/$group_name.txt"

    # Главный список: !#include на подправлен группы (в том же каталоге).
    printf '!#include %s.txt\n' "$group_name" >> "$DIST_DIR/filters.txt"
    echo "  -> dist/$group_name.txt" >&2
  fi
done

echo "=== Build complete ===" >&2
echo "Main list:  $DIST_DIR/filters.txt" >&2
