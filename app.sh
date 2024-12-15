#!/usr/bin/env bash

SHELLSMITH_DIR="${SHELLSMITH_WORKSPACE:-$HOME/.config/shellsmith}"
SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
APPS=()

if [[ ! -d "$SHELLSMITH_DIR/apps" ]]; then
  echo "Error: Apps directory '$SHELLSMITH_DIR/apps' is missing."
  echo "Please create a valid workspace."
  echo "See 'smith workspace help' for more information."

  exit 1
fi

export SHELLSMITH_DIR
source "$SCRIPT_DIR/app/app_handler.sh"
source "$SCRIPT_DIR/app/dependency_handler.sh"
source "$SCRIPT_DIR/app/app_installer.sh"

app_handler APPS

if [[ "${#APPS[@]}" -eq 0 ]]; then
  echo "No applications were selected. Exiting..."
  exit 1
fi

dependency_handler APPS
app_installer "${APPS[@]}"
