#!/usr/bin/env bash
# Общие функции для обработчиков групп.
# Подключается через: source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/../_lib/common.sh"
set -euo pipefail

# Обработчик группы — скрипт "$GROUP_DIR/handler.sh", вызывается build.sh как:
#   bash "$GROUP_DIR/handler.sh"
# Контракт: вывести итоговый список фильтров этой группы на stdout.
#
# Переменные окружения, выставляемые build.sh:
#   GROUP_NAME - имя группы (== имя папки)
#   GROUP_DIR  - абсолютный путь к папке группы

# Прочитать параметры группы из её $GROUP_DIR/config.sh, если он есть.
# config.sh — исполняемый shell-файл, экспортирующий нужные типу переменные.
# Управляющее свойство группы: GROUP_ENABLED=true|false (по умолчанию true).
load_group_config() {
  local config="$GROUP_DIR/config.sh"
  if [[ -f "$config" ]]; then
    # shellcheck disable=SC1090
    source "$config"
  fi
}

# Включена ли группа? Читает GROUP_ENABLED из уже загруженного config.
# По умолчанию (свойство отсутствует) группа считается включённой.
group_is_enabled() {
  [[ "${GROUP_ENABLED:-true}" == "true" ]]
}

# Вывести содержимое шаблона группы как есть.
dump_template() {
  cat "$GROUP_DIR/template.txt"
}
