#!/usr/bin/env bash

SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

show_help() {
  echo "Usage: $(basename "$0") <command> [args...]"
  echo ""
  echo "Commands:"
  echo "  run                   Run ShellSmith"
  echo "  workspace             Go-to workspace"
  echo "  update                Update ShellSmith"
  echo "  help                  Display this help message"
  echo ""
}

update_and_commit() {
  echo "Updating the .shellsmith submodule..."

  if ! git -C "$SHELLSMITH_WORKSPACE" submodule update --remote --recursive .shellsmith; then
    echo "Error updating the submodule. Please check your setup."
    return 1
  fi

  if ! git -C "$SHELLSMITH_WORKSPACE" diff --quiet -- .shellsmith; then
    echo "The .shellsmith submodule has been updated."
    read -p "Do you want to commit the update? (y/n): " choice
    if [[ "$choice" =~ ^[Yy]$ ]]; then
      git -C "$SHELLSMITH_WORKSPACE" add .shellsmith
      git -C "$SHELLSMITH_WORKSPACE" commit -m "update shellsmith to latest commit"
      echo "The update is commited to your workspace repository."
    else
      echo "The update was not commited."
    fi
  else
    echo "The .shellsmith submodule is already up-to-date."
  fi
}

go_to_workspace() {
  cd "$SHELLSMITH_WORKSPACE" || {
    echo "Error: Unable to change directory to $SHELLSMITH_WORKSPACE" >&2
    exit 1
  }
  $SHELL
}

if [[ $# -lt 1 ]]; then
  show_help
  exit 1
fi

command=$1
shift

case "$command" in
run)
  "$SCRIPT_DIR/app.sh"
  ;;
update)
  update_and_commit
  ;;
workspace)
  go_to_workspace
  ;;
help)
  show_help
  ;;
*)
  echo -e "\nUnknown command: $command\n"
  show_help
  exit 1
  ;;
esac
