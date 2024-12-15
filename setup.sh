#!/usr/bin/env bash

SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
SHELLSMITH_DIR="${SHELLSMITH_WORKSPACE:-$HOME/.config/shellsmith}"

install_shellsmith() {
  mkdir -p "$SHELLSMITH_DIR"
  sudo ln -s "$SCRIPT_DIR/sdk.sh" "/usr/local/bin/smith"
  echo "Setup complete."
}

uninstall_shellsmith() {
  read -p "Are you sure you want to remove ShellSmith? [y/N]: " -r
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Uninstall cancelled."
    exit 0
  fi

  if [[ -d "$SHELLSMITH_DIR" ]]; then
    read -p "Remove workspace at $SHELLSMITH_DIR? [y/N]: " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      if ! rm -rf "$SHELLSMITH_DIR"; then
        echo "Failed to remove workspace at $SHELLSMITH_DIR"
      fi
    fi
  fi

  if ! sudo rm -f "/usr/local/bin/smith"; then
    echo "Failed to remove /usr/local/bin/smith"
  fi

  echo "ShellSmith has been uninstalled from your system, including the workspace."
}

case "$1" in
install) install_shellsmith ;;
uninstall) uninstall_shellsmith ;;
*)
  echo "Usage: $0 [install|uninstall]"
  exit 1
  ;;
esac
