#!/usr/bin/env bash

show_help() {
  echo "Usage: smith <command> [args...]"
  echo ""
  echo "Commands:"
  echo "  run               Run ShellSmith"
  echo "  workspace         Open ShellSmith workspace"
  echo "  update <target>   Update ShellSmith components."
  echo "                    Targets:"
  echo "                       all          Update all."
  echo "                       shellsmith   Update only the ShellSmith submodule."
  echo "                       common       Update only the common workspace subtree."
  echo "  help              Display this help message"
  echo ""
}

update_and_commit() {
  target="$1"

  # Show help if target is not provided
  if [ -z "$target" ]; then
    show_help
    exit 1
  fi

  # Update the ShellSmith submodule if target is "shellsmith" or "all"
  if [ "$target" == "shellsmith" ] || [ "$target" == "all" ]; then
    echo "Updating ShellSmith in $SHELLSMITH_WORKSPACE..."
    echo ""
    if git -C "$SHELLSMITH_WORKSPACE" submodule update --remote --recursive .shellsmith; then
      if ! git -C "$SHELLSMITH_WORKSPACE" diff --quiet -- .shellsmith; then
        git -C "$SHELLSMITH_WORKSPACE" add .shellsmith
        git -C "$SHELLSMITH_WORKSPACE" commit -m "Update .shellsmith to the latest commit"
        echo "ShellSmith updated successfully."
      fi
    else
      echo "Failed to update ShellSmith."
      exit 1
    fi
  fi

  # Update the common subtree if target is "common" or "all"
  if [ "$target" == "common" ] || [ "$target" == "all" ]; then
    echo ""
    echo "Updating common workspace in $SHELLSMITH_WORKSPACE..."
    echo ""
    if git -C "$SHELLSMITH_WORKSPACE" subtree pull --prefix=common/ . common; then
      echo "Common workspace updated successfully."
    else
      echo "Failed to update common workspace."
      exit 1
    fi
  fi
}

if [[ $# -lt 1 ]]; then
  show_help
  exit 1
fi

command=$1
shift

case "$command" in
run)
  "$SHELLSMITH_ROOT/app.sh"
  ;;
update)
  update_and_commit "$@"
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
