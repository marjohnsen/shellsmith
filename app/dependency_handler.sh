#!/usr/bin/env bash

RESOLVED_APPS=""

# Load dependencies from the app script
load_dependencies() {
  local app_file="$SHELLSMITH_WORKSPACE/apps/$1.sh"
  local second_line
  second_line=$(sed -n '2p' "$app_file")

  if printf "%s\n" "$second_line" | grep -q '^:'; then
    printf "%s\n" "$second_line" | sed 's/^: *//; s/ *$//' | tr -s ' ' '\n'
  fi
}

# Resolve dependencies recursively for the selected app
trace_dependencies_recursively() {
  local app="$1"
  local dependencies

  if printf "%s\n" "$seen" | grep -qx "$app"; then
    return
  fi
  seen="$seen$app"$'\n'

  dependencies=$(load_dependencies "$app")

  while IFS= read -r dep; do
    [[ -n "$dep" ]] && trace_dependencies_recursively "$dep"
  done <<<"$dependencies"

  if ! printf "%s\n" "$resolved" | grep -qx "$app"; then
    resolved="$resolved$app"$'\n'
  fi
}

# Handle dependencies per app selected by the user
dependency_handler() {
  local selected_apps="$1"
  local resolved=""
  local seen=""
  local missing_dependencies=""

  # Trace dependencies
  while IFS= read -r app; do
    [[ -n "$app" ]] && trace_dependencies_recursively "$app"
  done <<<"$selected_apps"

  # Identify missing dependencies
  missing_dependencies=$(printf "%s\n" "$resolved" | grep -Fxv -f <(printf "%s\n" "$selected_apps") || true)

  # Step 1: Ask if dependencies should be resolved
  printf "\nWould you like to resolve dependencies for the selected apps? (yes/no): "
  read -r choice
  if [[ "$choice" != "yes" && "$choice" != "y" ]]; then
    printf "\n\033[1;31mUsing only selected apps, without resolving dependencies.\033[0m\n"
    printf "%s\n" "$selected_apps"
    return
  fi

  # Step 2: If dependencies are missing, ask if they should be added
  if [[ -n "$missing_dependencies" ]]; then
    printf "\n\033[1;33mThe following dependencies are missing:\033[0m\n"
    printf "%s\n" "$missing_dependencies"
    printf "\nWould you like to include them? (yes/no): "
    read -r choice
    if [[ "$choice" != "yes" && "$choice" != "y" ]]; then
      printf "\n\033[1;32mIgnoring missing dependencies but resolving the rest...\033[0m\n"
      resolved=$(printf "%s\n" "$resolved" | grep -Fxv -f <(printf "%s\n" "$missing_dependencies"))
    else
      printf "\n\033[1;32mIncluding missing dependencies...\033[0m\n"
    fi
  fi

  RESOLVED_APPS="${resolved%$'\n'}"
}

# When executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  if [[ -z "$SHELLSMITH_WORKSPACE" ]]; then
    read -e -r -p "Enter your ShellSmith workspace: " SHELLSMITH_WORKSPACE
    SHELLSMITH_WORKSPACE=$(realpath -m -- "${SHELLSMITH_WORKSPACE/#\~/$HOME}")
  fi
  dependency_handler "$(printf "%b" "$1")" "$2"
fi
