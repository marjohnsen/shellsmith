#!/usr/bin/env bash

SHELLSMITH_DIR="$1" && shift

# List available apps by reading .sh files in the ./apps directory
list_apps() {
  local apps=()
  for app in "$SHELLSMITH_DIR"/apps/*.sh; do
    apps+=("$(basename "$app" .sh)")
  done
  printf "%s\n" "${apps[@]}"
}

# Add the selected app to the list
select_app() {
  local app="$1"
  local -n ref_selected_apps="$2"
  if [[ ! " ${ref_selected_apps[*]} " =~ $app ]]; then
    ref_selected_apps+=("$app")
  fi
}

# Remove the selected app from the list
deselect_app() {
  local app="$1"
  local -n ref_selected_apps="$2"
  for i in "${!ref_selected_apps[@]}"; do
    if [[ "${ref_selected_apps[$i]}" == "$app" ]]; then
      unset 'ref_selected_apps[i]'
      break
    fi
  done
  ref_selected_apps=("${ref_selected_apps[@]}")
}

# Display available and selected apps with color formatting
display_apps() {
  local -n ref_available_apps="$1"
  local -n ref_selected_apps="$2"

  echo "Available apps:"
  for i in "${!ref_available_apps[@]}"; do
    if [[ ! " ${ref_selected_apps[*]} " =~ ${ref_available_apps[$i]} ]]; then
      echo -e "\033[1;31m$((i + 1))) ${ref_available_apps[$i]}\033[0m"
    fi
  done

  echo -e "\nSelected apps:"
  for i in "${!ref_available_apps[@]}"; do
    if [[ " ${ref_selected_apps[*]} " =~ ${ref_available_apps[$i]} ]]; then
      echo -e "\033[1;32m$((i + 1))) ${ref_available_apps[$i]}\033[0m"
    fi
  done
}

# Loop to select and deselect apps
app_handler() {
  local -n selected_apps_ref=$1
  local available_apps=()

  mapfile -t available_apps < <(list_apps)

  while true; do
    clear
    display_apps available_apps selected_apps_ref

    echo -e "\ns) \033[1;32mSelect all\033[0m"
    echo -e "d) \033[1;31mDeselect all\033[0m"
    echo -e "c) Continue"
    read -r choice

    case "$choice" in
    [0-9]*)
      local index=$((choice - 1))
      if ((index >= 0 && index < ${#available_apps[@]})); then
        if [[ " ${selected_apps_ref[*]} " =~ ${available_apps[$index]} ]]; then
          deselect_app "${available_apps[$index]}" selected_apps_ref
        else
          select_app "${available_apps[$index]}" selected_apps_ref
        fi
      fi
      ;;
    [Ss])
      for app in "${available_apps[@]}"; do
        select_app "$app" selected_apps_ref
      done
      ;;
    [Dd]) selected_apps_ref=() ;;
    [Cc])
      echo ""
      break
      ;;
    esac
  done
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  app_handler selected_apps "$@"
fi
