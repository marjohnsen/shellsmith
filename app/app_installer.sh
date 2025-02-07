#!/usr/bin/env bash

# Installs the apps passed as an argument
app_installer() {
  local apps="$1"

  echo "$apps" | while read -r app; do
    local app_script="$SHELLSMITH_WORKSPACE/apps/$app.sh"
    echo -e "\n\033[1;34mInstalling $app...\033[0m"

    if [[ -f "$app_script" ]]; then
      if bash "$app_script"; then
        echo -e "\033[1;32m✔ $app installed successfully.\033[0m"
      else
        echo -e "\033[1;31m✘ Failed to install $app. Exiting...\033[0m"
        exit 1
      fi
    else
      echo -e "\033[1;33m⚠ $app.sh not found in workspace: '$SHELLSMITH_WORKSPACE/apps'. Exiting...\033[0m"
      exit 1
    fi
  done
}

# When executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  if [[ -z "$SHELLSMITH_WORKSPACE" ]]; then
    read -r -p "Enter your ShellSmith workspace: " SHELLSMITH_WORKSPACE
    SHELLSMITH_WORKSPACE=$(cd "${SHELLSMITH_WORKSPACE/#\~/$HOME}" && pwd -P)
  fi
  app_installer "$*"
fi
