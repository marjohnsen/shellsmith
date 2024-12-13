#!/usr/bin/env bash

SHELLSMITH_DIR="${SHELLSMITH_ROOT:-$HOME/.config/.shellsmith}"
SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
APPS=()

if [[ ! -d "$SHELLSMITH_DIR/apps" ]]; then
  echo "Error: Apps directory '$SHELLSMITH_DIR/apps' is missing."
  echo "Create it with: mkdir -p '$SHELLSMITH_DIR/apps'"
  exit 1
fi

source "$SCRIPT_DIR/src/app_handler.sh"
source "$SCRIPT_DIR/src/dependency_handler.sh"
source "$SCRIPT_DIR/src/app_installer.sh"
app_handler SHELLSMITH_DIR APPS

if [[ "${#APPS[@]}" -eq 0 ]]; then
  echo "No applications were selected. Exiting..."
  exit 1
fi

dependency_handler SHELLSMITH_DIR APPS
app_installer SHELLSMITH_DIR "${APPS[@]}"
