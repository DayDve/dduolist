#!/usr/bin/env bash
# Обработчик (заглушка) статичной группы my-static.
# Контракт обработчика: вывести на stdout готовый список фильтров группы.
# Для статики это буквальное содержимое template.txt — никакой обработки.
set -euo pipefail

# shellcheck disable=SC1091
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/../_lib/common.sh"

dump_template
