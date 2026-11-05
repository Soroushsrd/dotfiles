#!/usr/bin/env bash
set -euo pipefail
if hyprctl getoption animations:enabled -j | python -c 'import json,sys; sys.exit(not bool(json.load(sys.stdin).get("int")))'; then
 hyprctl eval 'hl.config{animations={enabled=false}}'
else
 hyprctl eval 'hl.config{animations={enabled=true}}'
fi
