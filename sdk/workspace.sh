#!/usr/bin/env bash

SHELLSMITH_DIR="${SHELLSMITH_WORKSPACE:-$HOME/.config/shellsmith}"
SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

show_help() {
  echo "Usage: smith workspace <command> [args...]"
  echo ""
  echo "Commands:"
  echo "  create                Create ShellSmith workspace. Creates backup of exisitng workspace."
  echo "  delete                Delete current ShellSmith workspace. Prompts for confirmation."
  echo "  clone <repo>          Clone Git repository into the ShellSmith workspace. Creates backup of existing workspace."
  echo "  goto                  Navigate to the ShellSmith workspace directory."
  echo "  help                  Display this help message."
  echo ""
}

create_new_workspace() {
  if [[ -d "$SHELLSMITH_DIR" && -n "$(ls -A "$SHELLSMITH_DIR")" ]]; then
    echo "Workspace at $SHELLSMITH_DIR already exists and is not empty."
    backup_workspace
  fi

  mkdir -p "$SHELLSMITH_DIR/apps"

  echo "utils/" >"$SHELLSMITH_DIR/.gitignore"

  echo "#!/usr/bin/env bash" >"$SHELLSMITH_DIR/init.sh"
  echo "# This file will always be execute first." >>"$SHELLSMITH_DIR/init.sh"
  echo "# Can be used to install basic stuff from package managers and such." >>"$SHELLSMITH_DIR/init.sh"

  ln -s "$SCRIPT_DIR/../utils" "$SHELLSMITH_DIR/utils"
  echo "Finished setting up new workspace at $SHELLSMITH_DIR."
}

delete_workspace() {
  read -p "Delete workspace at $SHELLSMITH_DIR? [y/N]: " -r
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    if rm -rf "$SHELLSMITH_DIR"; then
      echo "Workspace deleted."
    else
      echo "Failed to remove workspace at $SHELLSMITH_DIR."
    fi
  else
    echo "Delete operation cancelled."
  fi
}

backup_workspace() {
  local backup_dir
  backup_dir="$(dirname "$SHELLSMITH_DIR")/shellsmith$(date +%s).bak"
  echo "Creating backup of existing workspace at $backup_dir..."
  if mv "$SHELLSMITH_DIR" "$backup_dir"; then
    echo "Backup created successfully."
  else
    echo "Failed to create backup. Exiting."
    exit 1
  fi
}

clone_repository() {
  if [[ $# -lt 1 ]]; then
    echo "Usage: smith workspace clone <repo>"
    exit 1
  fi

  local repo=$1

  if [[ -d "$SHELLSMITH_DIR" && -n "$(ls -A "$SHELLSMITH_DIR")" ]]; then
    echo "Workspace at $SHELLSMITH_DIR already exists and is not empty."
    backup_workspace
  fi

  echo "Cloning repository into $SHELLSMITH_DIR..."
  if git clone "$repo" "$SHELLSMITH_DIR"; then
    ln -s "$SCRIPT_DIR/../utils" "$SHELLSMITH_DIR/utils"
    echo "Repository cloned successfully."
  else
    echo "Failed to clone repository."
    exit 1
  fi
}

goto_workspace() {
  if [[ -d "$SHELLSMITH_DIR" ]]; then
    if cd "$SHELLSMITH_DIR"; then
      echo "Moved to workspace directory: $SHELLSMITH_DIR"
    else
      echo "Failed to change directory to $SHELLSMITH_DIR."
      exit 1
    fi
  else
    echo "Workspace does not exist at $SHELLSMITH_DIR."
    exit 1
  fi
}

if [[ $# -lt 1 ]]; then
  show_help
  exit 1
fi

command=$1
shift

case "$command" in
create)
  create_workspace
  ;;
delete)
  delete_workspace
  ;;
clone)
  clone_repository "$@"
  ;;
goto)
  goto_workspace
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
