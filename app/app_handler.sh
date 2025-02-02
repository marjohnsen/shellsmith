#!/usr/bin/env bash

# List available apps by reading .sh files in the ./apps directory
list_apps() {
  for app in "$SHELLSMITH_WORKSPACE"/apps/*.sh; do
    basename "$app" .sh
  done
}

# Add the selected app to the list
select_app() {
  local apps="$1"
  local app="$2"
  echo -e "$apps\n$app" | awk '!seen[$0]++'
}

# Remove the selected app from the list
deselect_app() {
  local apps="$1"
  local app="$2"
  echo "$apps" | grep -vx "$app"
}

# Display available and selected apps
display_apps() {
  local available="$1"
  local selected="$2"

  available=$(echo "$available" | awk '{print NR, $0}')

  echo "Available apps:" >/dev/tty
  echo "$available" | while read -r index app; do
    if ! echo "$selected" | grep -qx "$app"; then
      echo -e "\033[1;31m$index. $app\033[0m" >/dev/tty
    fi
  done

  echo -e "\nSelected apps:" >/dev/tty
  echo "$available" | while read -r index app; do
    if echo "$selected" | grep -qx "$app"; then
      echo -e "\033[1;32m$index. $app\033[0m" >/dev/tty
    fi
  done
}

# Terminal menu to select apps to install
app_handler() {
  local app
  local available
  local selected=""

  available=$(list_apps)

  while true; do
    clear >/dev/tty
    display_apps "$available" "$selected"

    echo -e "\ns) \033[1;32mSelect all\033[0m" >/dev/tty
    echo -e "d) \033[1;31mDeselect all\033[0m" >/dev/tty
    echo -e "c) Continue" >/dev/tty

    read -r choice </dev/tty

    case "$choice" in
    [0-9]*)
      app=$(echo "$available" | sed -n "${choice}p")
      if [ -n "$app" ]; then
        if echo "$selected" | grep -qx "$app"; then
          selected=$(deselect_app "$selected" "$app")
        else
          selected=$(select_app "$selected" "$app")
        fi
      fi
      ;;
    [Ss]) selected="$available" ;;
    [Dd]) selected="" ;;
    [Cc]) break ;;
    esac
  done

  echo -e "$selected"
}

# Example usage
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  if [[ -z "$SHELLSMITH_WORKSPACE" ]]; then
    read -e -r -p "Enter your ShellSmith workspace: " SHELLSMITH_WORKSPACE
    SHELLSMITH_WORKSPACE=$(realpath -m -- "${SHELLSMITH_WORKSPACE/#\~/$HOME}")
  fi
  app_handler
fi
