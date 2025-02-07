#!/usr/bin/env bash

SELECTED_APPS=""

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
  if [ -z "$apps" ]; then
    printf "%s\n" "$app"
  else
    printf "%s\n%s\n" "$apps" "$app" | awk '!seen[$0]++'
  fi
}

# Remove the selected app from the list
deselect_app() {
  local apps="$1"
  local app="$2"
  printf "%s\n" "$apps" | grep -vx "$app"
}

# Display available and selected apps
display_apps() {
  local available="$1"
  local selected="$2"

  available=$(printf "%s\n" "$available" | awk '{print NR, $0}')

  printf "Available apps:\n"
  printf "%s\n" "$available" | while read -r index app; do
    if ! printf "%s\n" "$selected" | grep -qx "$app"; then
      printf "\033[1;31m%s. %s\033[0m\n" "$index" "$app"
    fi
  done

  printf "\nSelected apps:\n"
  printf "%s\n" "$available" | while read -r index app; do
    if printf "%s\n" "$selected" | grep -qx "$app"; then
      printf "\033[1;32m%s. %s\033[0m\n" "$index" "$app"
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
    clear
    display_apps "$available" "$selected"

    printf "\ns) \033[1;32mSelect all\033[0m\n"
    printf "d) \033[1;31mDeselect all\033[0m\n"
    printf "c) Continue\n"

    read -r choice </dev/tty

    case "$choice" in
    [0-9]*)
      app=$(printf "%s\n" "$available" | sed -n "${choice}p")
      if [[ -n "$app" ]]; then
        if printf "%s\n" "$selected" | grep -qx "$app"; then
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

  SELECTED_APPS="$selected"
}

# When executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  if [[ -z "$SHELLSMITH_WORKSPACE" ]]; then
    read -r -p "Enter path to your ShellSmith workspace: " SHELLSMITH_WORKSPACE
    SHELLSMITH_WORKSPACE=$(cd "${SHELLSMITH_WORKSPACE/#\~/$HOME}" && pwd -P)
  fi
  app_handler
fi
