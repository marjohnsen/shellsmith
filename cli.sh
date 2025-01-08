#!/usr/bin/env bash

SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

show_help() {
  echo "Usage: $(basename "$0") <command> [args...]"
  echo ""
  echo "Commands:"
  echo "  run                   Run ShellSmith."
  echo "  update                Update ShellSmith."
  echo "  help                  Display this help message."
  echo ""
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
  git -C "$SHELLSMITH_WORKSPACE" submodule update --remote --recursive
  ;;
workspace)
  cd "$SHELLSMITH_WORKSPACE" || {
    echo "Error: Unable to change directory to $SHELLSMITH_WORKSPACE" >&2
    exit 1
  }
  $SHELL
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
