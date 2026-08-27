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

# shellcheck disable=SC1091
source "$ROOT/groups/_lib/common.sh"

shopt -s nullglob
group_dirs=("$GROUPS_DIR"/*/)
shopt -u nullglob

if [[ ${#group_dirs[@]} -eq 0 ]]; then
  echo "No groups found in $GROUPS_DIR" >&2
  exit 1
fi

cat > "$DIST_DIR/filters.txt" <<'EOF'
! Title: DayDve uBlock Filter Groups
! Expires: 1 days
! Homepage: https://github.com/DayDve/dduolist

EOF

for group_dir in "${group_dirs[@]}"; do
  group_dir="${group_dir%/}"
  group_name="$(basename "$group_dir")"

  if [[ "$group_name" == "_lib" ]]; then
    continue
  fi

  if [[ ! -f "$group_dir/handler.sh" ]]; then
    echo "ERROR: $group_name has no handler.sh, skipping" >&2
    continue
  fi

  # Считываем свойство группы GROUP_ENABLED (по умолчанию true) из config.sh.
  enabled=true
  if [[ -f "$group_dir/config.sh" ]]; then
    enabled="$(GROUP_NAME="$group_name" GROUP_DIR="$group_dir" bash -c '
      source "$GROUP_DIR/config.sh"
      printf "%s" "${GROUP_ENABLED:-true}"
    ')"
  fi

  echo "Processing group: $group_name (enabled=$enabled)" >&2

  GROUP_NAME="$group_name" \
  GROUP_DIR="$group_dir" \
    bash "$group_dir/handler.sh" > "$DIST_DIR/$group_name.txt"
  echo "  -> dist/$group_name.txt" >&2

  if [[ "$enabled" == "true" ]]; then
    printf '!#include %s.txt\n' "$group_name" >> "$DIST_DIR/filters.txt"
  else
    echo "  (disabled: no !#include added)" >&2
  fi
done

echo "=== Build complete ===" >&2
echo "Main list:  $DIST_DIR/filters.txt" >&2
