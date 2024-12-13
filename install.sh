#!/usr/bin/env bash

SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

source "$SCRIPT_DIR/utils/app_interface.sh"

mkdir -p "$HOME/.config/.shellsmith/apps"

safe_symlink "$SCRIPT_DIR"/ShellSmith.sh /usr/local/bin/smith
