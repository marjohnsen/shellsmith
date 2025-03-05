#!/usr/bin/env bash

show_help() {
  echo "Usage: smith <command> [args...]"
  echo ""
  echo "Commands:"
  echo "  run               Run ShellSmith"
  echo "  workspace         Open ShellSmith workspace"
  echo "  update <target>   Update a submodule. Targets:"
  echo "                      shellsmith - Update ShellSmith."
  echo "                      shared     - Update shared workspace."
  echo "  help              Display this help message"
  echo ""
}

update_submodule() {
  local name="$1"

  echo -e "\nUpdating $name...\n"
  if git -C "$SHELLSMITH_WORKSPACE" submodule update --remote --recursive "$name"; then
    if ! git -C "$SHELLSMITH_WORKSPACE" diff --quiet -- "$name"; then
      git -C "$SHELLSMITH_WORKSPACE" add "$name"
      git -C "$SHELLSMITH_WORKSPACE" commit -m "Update $name to the latest commit"
    else
      echo "$name is already up to date."
    fi
  else
    echo "Failed to update $name."
    exit 1
  fi
}

if [[ $# -lt 1 ]]; then
  show_help
  exit 1
fi

case "$1" in
run)
  "$SHELLSMITH_ROOT/app.sh"
  ;;

workspace)
  go_to_workspace
  ;;

update)
  case "$2" in
  shellsmith | shared)
    update_submodule "$2"
    ;;
  *)
    echo "Unknown update command: $1"
    show_help
    exit 1
    ;;
  esac
  ;;

help)
  show_help
  ;;
*)
  echo "Unknown command: $1"
  show_help
  exit 1
  ;;
esac
