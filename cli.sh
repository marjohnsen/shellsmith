#!/usr/bin/env bash

show_help() {
  echo "Usage: smith <command> [args...]"
  echo ""
  echo "Commands:"
  echo "  run               Run ShellSmith"
  echo "  workspace         Open ShellSmith workspace"
  echo "  update            Update the ShellSmith submodule."
  echo "  common <option>   Update common workspace. Options:"
  echo "                      push - Push changes from the common/ folder into the common branch."
  echo "                      pull - Pull changes from the common branch into the common/ folder."
  echo "  help              Display this help message"
  echo ""
}

update_shellsmith() {
  echo ""
  echo "Updating ShellSmith in $SHELLSMITH_WORKSPACE..."
  echo ""
  if git -C "$SHELLSMITH_WORKSPACE" submodule update --remote --recursive .shellsmith; then
    if ! git -C "$SHELLSMITH_WORKSPACE" diff --quiet -- .shellsmith; then
      git -C "$SHELLSMITH_WORKSPACE" add .shellsmith
      git -C "$SHELLSMITH_WORKSPACE" commit -m "Update .shellsmith to the latest commit"
    else
      echo "ShellSmith submodule is already up to date."
    fi
  else
    echo "Failed to update ShellSmith submodule."
    exit 1
  fi
}

update_common_workspace() {
  local action="$1"
  case "$action" in
  push)
    echo ""
    echo "Pushing changes from to the common branch..."
    echo ""
    if ! git -C "$SHELLSMITH_WORKSPACE" subtree push --prefix=common origin origin/common; then
      echo "Failed to push common workspace."
      exit 1
    fi
    ;;
  pull)
    echo ""
    echo "Pulling changes from the common branch..."
    echo ""
    if ! git -C "$SHELLSMITH_WORKSPACE" subtree pull --prefix=common/ . origin/common; then
      echo "Failed to pull common workspace."
      exit 1
    fi
    ;;
  *)
    show_help
    exit 1
    ;;
  esac
}

if [[ $# -lt 1 ]]; then
  show_help
  exit 1
fi

command="$1"
shift

case "$command" in
run)
  "$SHELLSMITH_ROOT/app.sh"
  ;;
update)
  update_shellsmith
  ;;
common)
  update_common_workspace "$1"
  ;;
workspace)
  go_to_workspace
  ;;
help)
  show_help
  ;;
*)
  echo "Unknown command: $command"
  show_help
  exit 1
  ;;
esac
