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

# Handle dependencies per app selected by the user
dependency_handler() {
  local selected_apps="$1"
  local missing_dependencies=""
  local resolved
  local seen

  # Resolve dependencies recursively for the selected app
  trace_dependencies_recursively() {
    local app="$1"
    local dependencies

    if printf "%s\n" "$seen" | grep -qx "$app"; then
      return
    fi
    seen="${seen:+$seen$'\n'}$app"
    dependencies=$(load_dependencies "$app")

    while IFS= read -r dep; do
      [[ -n "$dep" ]] && trace_dependencies_recursively "$dep"
    done <<<"$dependencies"

    if ! printf "%s\n" "$resolved" | grep -qx "$app"; then
      resolved="${resolved:+$resolved$'\n'}$app"
    fi
  }

  # Trace dependencies
  while IFS= read -r app; do
    [[ -n "$app" ]] && trace_dependencies_recursively "$app"
  done <<<"$selected_apps"

  # Identify missing dependencies
  missing_dependencies=$(printf "%s\n" "$resolved" | grep -Fxv -f <(printf "%s\n" "$selected_apps") || true)

  # Ask if dependencies should be resolved
  printf "\nWould you like to resolve dependencies for the selected apps? (yes/no): "
  read -r choice
  # if no, use only selected apps
  if [[ ! "$choice" =~ ^[Yy]([Ee][Ss])?$ ]]; then
    printf "\n\033[1;33mContinue without resolving dependencies..\033[0m\n"
    RESOLVED_APPS="${selected_apps}"
  # if yes and no missing dependencies, use resolved apps
  elif [[ -z "$missing_dependencies" ]]; then
    printf "\n\033[1;33mNo missing dependencies, resolving selected..\033[0m\n"
    RESOLVED_APPS="${resolved}"
  # if yes and missing dependencies, ask if they should be added
  elif [[ -n "$missing_dependencies" ]]; then
    printf "\n\033[1;33mThe following dependencies are missing:\033[0m\n"
    printf "%s\n" "$missing_dependencies"
    printf "\nWould you like to include them? (yes/no): "
    read -r choice
    if [[ ! "$choice" =~ ^[Yy]([Ee][Ss])?$ ]]; then
      printf "\n\033[1;33mIgnoring missing dependencies, resolving selected..\033[0m\n"
      resolved=$(printf "%s\n" "$resolved" | grep -Fxv -f <(printf "%s\n" "$missing_dependencies"))
    else
      printf "\n\033[1;33mIncluding missing dependencies, resolving all..\033[0m\n"
    fi
    RESOLVED_APPS="${resolved}"
  fi

  # Move init to the beginning of the resolved list if present
  if [ "$RESOLVED_APPS" != "init" ]; then
    if printf "%s\n" "$RESOLVED_APPS" | grep -q "^init$"; then
      RESOLVED_APPS=$(printf "init\n%s\n" "$(printf "%s\n" "$RESOLVED_APPS" | grep -v "^init$")")
    fi
  fi

  # Display resolved dependencies
  printf "\n\033[1;32mInstall order:\033[0m\n"
  printf "%s\n" "$RESOLVED_APPS"
  printf "\nDo you want to proceed with the following install order? (yes/no): "

  # Ask for confirmation
  read -r choice
  if [[ ! "$choice" =~ ^[Yy]([Ee][Ss])?$ ]]; then
    printf "\n\033[1;31mAborting installation...\033[0m\n"
    exit 1
  fi
}

# When executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  if [[ -z "$SHELLSMITH_WORKSPACE" ]]; then
    read -r -p "Enter your ShellSmith workspace: " SHELLSMITH_WORKSPACE
    SHELLSMITH_WORKSPACE=$(cd "${SHELLSMITH_WORKSPACE/#\~/$HOME}" && pwd -P)
  fi
  dependency_handler "$(printf "%b" "$1")" "$2"
fi
