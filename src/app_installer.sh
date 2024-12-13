#!/usr/bin/env bash

SHELLSMITH_DIR="$1" && shift

install_handler() {
  local apps=("$@")

  for app in "${apps[@]}"; do
    local app_script="$SHELLSMITH_DIR/apps/$app.sh"

    echo -e "\n\033[1;34mInstalling $app...\033[0m"

    if [[ -f "$app_script" ]]; then
      if bash "$app_script"; then
        echo -e "\033[1;32m✔ $app installed successfully.\033[0m"
      else
        echo -e "\033[1;31m✘ Failed to install $app. Exiting...\033[0m"
        exit 1
      fi
    else
      echo -e "\033[1;33m⚠ $app.sh not found in '$SHELLSMITH_DIR/apps'. Exiting...\033[0m"
      exit 1
    fi
  done
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_apps "$@"
fi
