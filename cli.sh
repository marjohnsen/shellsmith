#!/usr/bin/env bash

show_help() {
  echo "Usage: $(basename "$0") <command> [args...]"
  echo ""
  echo "Commands:"
  echo "  run                   Run ShellSmith"
  echo "  workspace             Go-to ShellSmith workspace"
  echo "  update                Update ShellSmith"
  echo "  help                  Display this help message"
  echo ""
}

update_and_commit() {
  echo "Updating the .shellsmith submodule in $SHELLSMITH_WORKSPACE..."
  echo ""

  if ! git -C "$SHELLSMITH_WORKSPACE" submodule update --remote --recursive .shellsmith; then
    echo "Failed to update the .shellsmith submodule. Please verify your configuration and try again."
    return 1
  fi

  if ! git -C "$SHELLSMITH_WORKSPACE" diff --quiet -- .shellsmith; then
    echo ""
    echo "The .shellsmith submodule has been updated to the latest version."
    read -p "Would you like to commit the changes to your repository? (y/n): " choice
    if [[ "$choice" =~ ^[Yy]$ ]]; then
      echo ""
      git -C "$SHELLSMITH_WORKSPACE" add .shellsmith
      git -C "$SHELLSMITH_WORKSPACE" commit -m "Update .shellsmith to the latest commit"
      echo ""
      echo "Changes have been successfully committed to your workspace repository."
    else
      echo "Update completed, but changes were not committed."
    fi
  else
    echo "The .shellsmith submodule is already up to date. No changes detected."
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
  "$SHELLSMITH_WORKSPACE_APPS/app.sh"
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
