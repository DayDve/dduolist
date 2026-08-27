#!/usr/bin/env bash
# Параметры группы kp-mirrors (зеркала Кинопоиска/KP).
# Динамика: список DOMAINS строится из известных + актуального из редиректа.
# Переменные экспортируются и читаются обработчиком handler.sh.

# URL, редирект которого ведёт на актуальный зеркальный домен.
export REDIRECT_URL="https://kinokino.vip/film/12930515/"

# Постоянно известные зеркальные домены (якорь, не пропадают).
export KNOWN_DOMAINS="fbfind.top,fbfree.cfd,fbsite.top"

# Плейсхолдер в template.txt, заменяемый списком доменов.
export DOMAINS_PLACEHOLDER="__DOMAINS__"
