#!/usr/bin/env bash

SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

show_help() {
  echo "Usage: $(basename "$0") <command> [args...]"
  echo ""
  echo "Commands:"
  echo "  run                   Run ShellSmith."
  echo "  workspace             Manage and create the ShellSmith workspace."
  echo "  uninstall             Uninstall ShellSmith from your system."
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
workspace)
  "$SCRIPT_DIR/cli/workspace.sh" "$@"
  ;;
uninstall)
  "$SCRIPT_DIR/setup.sh" uninstall
  ;;
help)
  show_help
  ;;
*)
  echo ""
  echo "Unknown command: $command"
  echo ""
  show_help
  exit 1
  ;;
esac
