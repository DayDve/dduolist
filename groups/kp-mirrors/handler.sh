#!/usr/bin/env bash
# Обработчик группы kp-mirrors (зеркала Кинопоиска/KP).
# Выводит на stdout список фильтров с актуальным списком зеркальных доменов:
#   известные домены + домен, полученный из редиректа REDIRECT_URL.
# Если редирект не сработал — НЕ падаем: используем только известные домены.
set -euo pipefail

# shellcheck disable=SC1091
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/../_lib/common.sh"
load_group_config

detect_domain() {
  local redirect_url
  redirect_url=$(curl -fsI "$REDIRECT_URL" -w '%header{location}' -o /dev/null || true)
  if [[ -n "$redirect_url" ]]; then
    echo "$redirect_url" | awk -F[/:] '{print $4}'
  fi
}

current_domain="$(detect_domain)"
if [[ -z "$current_domain" ]]; then
  echo "WARN: no redirect from $REDIRECT_URL, using known domains only" >&2
  all_domains="$KNOWN_DOMAINS"
elif [[ ",$KNOWN_DOMAINS," == *",$current_domain,"* ]]; then
  all_domains="$KNOWN_DOMAINS"
else
  all_domains="${KNOWN_DOMAINS},${current_domain}"
fi

echo "INFO: using domains: $all_domains" >&2
sed "s/$DOMAINS_PLACEHOLDER/$all_domains/g" "$GROUP_DIR/template.txt"
