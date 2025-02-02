#!/usr/bin/env bash

# Load dependencies from the app script
load_dependencies() {
  local app="$SHELLSMITH_WORKSPACE/apps/$1.sh"
  local first_double_slash_line
  first_double_slash_line=$(sed -n '/^\/\/ /{s/^\/\/ //;p;q;}' "$app")
  echo -e "$first_double_slash_line" | tr ' ' '\n'
}

# Resolve dependencies recursively for the selected app
trace_dependencies_recursively() {
  local app="$1"
  local dependencies

  if echo -e "$seen" | grep -qx "$app"; then
    return
  fi
  seen="$seen$app"$'\n'

  dependencies=$(load_dependencies "$app")

  while IFS= read -r dep; do
    [[ -n "$dep" ]] && trace_dependencies_recursively "$dep"
  done <<<"$dependencies"

  if ! echo -e "$resolved" | grep -qx "$app"; then
    resolved="$resolved$app"$'\n'
  fi
}

# Handle dependencies per app selected by the user
dependency_handler() {
  local selected_apps="$1"
  local resolved=""
  local seen=""
  local missing_dependencies=""

  # Trace dependencies for each selected app
  while IFS= read -r app; do
    [[ -n "$app" ]] && trace_dependencies_recursively "$app"
  done <<<"$selected_apps"

  # Identify missing dependencies
  missing_dependencies=$(echo -e "$resolved" | grep -Fxv -f <(echo -e "$selected_apps") || true)

  # Step 1: Ask if dependencies should be resolved
  echo -e "\nWould you like to resolve dependencies for the selected apps? (yes/no): " >/dev/tty
  read -r choice </dev/tty
  if [[ "$choice" != "yes" && "$choice" != "y" ]]; then
    echo -e "\n\033[1;31mUsing only selected apps, without resolving dependencies.\033[0m\n" >/dev/tty
    echo -e "$selected_apps"
    return
  fi

  # Step 2: If dependencies are missing, ask if they should be added
  if [[ -n "$missing_dependencies" ]]; then
    echo -e "\n\033[1;33mThe following dependencies are missing:\033[0m" >/dev/tty
    echo -e "$missing_dependencies" >/dev/tty
    echo -e "\nWould you like to include them? (yes/no): " >/dev/tty
    read -r choice </dev/tty
    if [[ "$choice" != "yes" && "$choice" != "y" ]]; then
      echo -e "\n\033[1;32mIgnoring missing dependencies but resolving the rest...\033[0m\n" >/dev/tty
      resolved=$(echo -e "$resolved" | grep -Fxv -f <(echo -e "$missing_dependencies"))
    else
      echo -e "\n\033[1;32mIncluding missing dependencies...\033[0m\n" >/dev/tty
    fi
  fi

  echo -e "$resolved"
}

# Example usage
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  if [[ -z "$SHELLSMITH_WORKSPACE" ]]; then
    read -e -r -p "Enter your ShellSmith workspace: " SHELLSMITH_WORKSPACE </dev/tty
    SHELLSMITH_WORKSPACE=$(realpath -m -- "${SHELLSMITH_WORKSPACE/#\~/$HOME}")
  fi
  dependency_handler "$(printf "%b" "$1")" "$2"
fi
