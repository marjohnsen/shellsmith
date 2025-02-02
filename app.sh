#!/usr/bin/env bash

set -e
set -o pipefail
set -E

trap 'echo "[ERROR] Command \"${BASH_COMMAND}\" failed at line ${LINENO} in script ${BASH_SOURCE[0]}. Exiting..." >&2; exit 1' ERR

source "$SHELLSMITH_ROOT/app/app_handler.sh" || exit 1
source "$SHELLSMITH_ROOT/app/dependency_handler.sh" || exit 1
source "$SHELLSMITH_ROOT/app/app_installer.sh" || exit 1

if [[ ! -d "$SHELLSMITH_WORKSPACE/apps" ]]; then
  echo "Error: Apps directory '$SHELLSMITH_WORKSPACE/apps' is missing."
  echo "Please create a valid workspace."
  exit 1
fi

cd "$SHELLSMITH_WORKSPACE/apps" || exit 1

selected_apps=$(app_handler)

if [[ -z "$selected_apps" ]]; then
  echo "No applications were selected. Exiting..."
  exit 1
fi

selected_apps_ordered=$(dependency_handler "$selected_apps")

app_installer "$selected_apps_ordered"
