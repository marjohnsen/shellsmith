#!/usr/bin/env bash

set -e
set -o pipefail
set -E

trap 'echo "[ERROR] Command \"${BASH_COMMAND}\" failed at line ${LINENO} in script ${BASH_SOURCE[0]}. Exiting..." >&2; exit 1' ERR

APPS=()

if [[ ! -d "$SHELLSMITH_WORKSPACE/apps" ]]; then
  echo "Error: Apps directory '$SHELLSMITH_WORKSPACE/apps' is missing."
  echo "Please create a valid workspace."

  exit 1
fi

cd "$SHELLSMITH_WORKSPACE/apps" || return

export SHELLSMITH_DIR
source "$SHELLSMITH_ROOT/app/app_handler.sh"
source "$SHELLSMITH_ROOT/app/dependency_handler.sh"
source "$SHELLSMITH_ROOT/app/app_installer.sh"

app_handler APPS

if [[ "${#APPS[@]}" -eq 0 ]]; then
  echo "No applications were selected. Exiting..."
  exit 1
fi

dependency_handler APPS
app_installer "${APPS[@]}"
