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
  local ws="$SHELLSMITH_WORKSPACE"

  case "$action" in
    push)
      echo -e "\nPushing 'common/' to 'common' branch...\n"
      git -C "$ws" subtree split --prefix=common -b common-split &&
      git -C "$ws" push origin common-split:common &&
      git -C "$ws" branch -D common-split &&
      echo "Push successful." || { echo "Error: Push failed."; exit 1; }
      ;;
    
    pull)
      echo -e "\nPulling 'common' branch into 'common/'...\n"
      git -C "$ws" subtree pull --prefix=common origin common &&
      echo "Pull successful." || { echo "Error: Pull failed."; exit 1; }
      ;;
    
    *)
     show_help
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
