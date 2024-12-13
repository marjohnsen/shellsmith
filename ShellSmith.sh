#!/usr/bin/env bash

APPS_DIR="${SHELLSMITH_APPS_DIR:-$HOME/.config/.shellsmith/apps}"
SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
APPS=()

if [[ ! -d "$APPS_DIR" ]]; then
  echo "Error: Apps directory '$APPS_DIR' is missing."
  echo "Create it with: mkdir -p '$HOME/.config/.shellsmith/apps'"
  echo "Or set SHELLSMITH_APPS_DIR in your shell configuration."
  exit 1
fi

source "$SCRIPT_DIR/src/app_handler.sh"
source "$SCRIPT_DIR/src/dependency_handler.sh"
source "$SCRIPT_DIR/src/app_installer.sh"

app_handler APPS_DIR APPS

if [[ "${#APPS[@]}" -eq 0 ]]; then
  echo "No applications were selected. Exiting..."
  exit 1
fi

dependency_handler APPS_DIR APPS
app_installer APPS_DIR "${APPS[@]}"
