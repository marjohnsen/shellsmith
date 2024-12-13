#!/usr/bin/env bash

SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
SHELLSMITH_DIR="${SHELLSMITH_ROOT:-$HOME/.config/.shellsmith}"

source "$SCRIPT_DIR/utils/app_interface.sh"

mkdir -p "$SHELLSMITH_DIR/apps"

safe_symlink "$SCRIPT_DIR/ShellSmith.sh" "/usr/local/bin/smith"
safe_symlink "$SCRIPT_DIR/utils" "$SHELLSMITH_DIR/utils"
