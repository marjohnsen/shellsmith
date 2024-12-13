#!/usr/bin/env bash

SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
SHELLSMITH_DIR="${SHELLSMITH_ROOT:-$HOME/.config/.shellsmith}"

mkdir -p "$SHELLSMITH_DIR/apps"

ln -s "$SCRIPT_DIR/utils" "$SHELLSMITH_DIR/utils"
sudo ln -s "$SCRIPT_DIR/ShellSmith.sh" "/usr/local/bin/smith"
