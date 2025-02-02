#!/usr/bin/env bash

# Load dependencies from the app script
load_dependencies() {
  local app="$SHELLSMITH_WORKSPACE/apps/$1.sh"
  local first_double_slash_line
  first_double_slash_line=$(sed -n '/^\/\/ /{s/^\/\/ //;p;q;}' "$app")
  echo "$first_double_slash_line" | tr ' ' '\n'
}

# Resolve dependencies recursively for the selected app
trace_dependencies_recursively() {
  local app="$1"
  local dependencies

  if echo "$seen" | grep -qx "$app"; then
    return
  fi
  seen="$seen$app"$'\n'

  dependencies=$(load_dependencies "$app")

  while IFS= read -r dep; do
    [[ -n "$dep" ]] && trace_dependencies_recursively "$dep"
  done <<<"$dependencies"

  if ! echo "$resolved" | grep -qx "$app"; then
    resolved="$resolved$app"$'\n'
  fi
}

# Handle dependencies for the apps passed as an argument
dependency_handler() {
  local selected_apps="$1"
  local include_missing_deps="$2"
  local resolved=""
  local seen=""

  while IFS= read -r app; do
    [[ -n "$app" ]] && trace_dependencies_recursively "$app"
  done <<<"$selected_apps"

  if [[ "$include_missing_deps" == "false" ]]; then
    resolved=$(echo "$resolved" | grep -Fx -f <(echo "$selected_apps"))
  fi

  printf "%s\n" "$resolved"
}

# Example usage
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  if [[ -z "$SHELLSMITH_WORKSPACE" ]]; then
    read -e -r -p "Enter your ShellSmith workspace: " SHELLSMITH_WORKSPACE
    SHELLSMITH_WORKSPACE=$(realpath -m -- "${SHELLSMITH_WORKSPACE/#\~/$HOME}")
  fi
  dependency_handler "$(printf "%b" "$1")" "$2"
fi
