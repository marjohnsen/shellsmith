#!/usr/bin/env bash

set -e

SHELLSMITH_LAUNCH="$HOME/.local/bin/smith"
SHELLSMITH_ROOT="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
SHELLSMITH_WORKSPACE="$(realpath "$SHELLSMITH_ROOT/../")"
SHELLSMITH_DOTFILES="$SHELLSMITH_WORKSPACE/dotfiles"
SHELLSMITH_APPS="$SHELLSMITH_WORKSPACE/apps"
SHELLSMITH_MISC="$SHELLSMITH_WORKSPACE/misc"
SHELLSMITH_UTILS="$SHELLSMITH_ROOT/utils"

verify_submodule() {
  git config --file "$SHELLSMITH_WORKSPACE/.gitmodules" --get-regexp path | grep -q "\.shellsmith" || {
    echo "Error: ShellSmith must be installed as a submodule under a ShellSmith workspace." >&2
    echo "Learn more at https://github.com/marjohnsen/shellsmith_workspace." >&2
    exit 1
  }
}

update_submodules() {
  echo "Updating submodules in $SHELLSMITH_WORKSPACE..."
  git -C "$SHELLSMITH_WORKSPACE" submodule update --init --recursive
  git -C "$SHELLSMITH_WORKSPACE" submodule update --remote
}

enable_merge_workflow() {
  echo "Configuring pull.rebase=false for $SHELLSMITH_WORKSPACE..."
  git -C "$SHELLSMITH_WORKSPACE" config pull.rebase false
  echo "Enabling submodule.recurse=true for $SHELLSMITH_WORKSPACE..."
  git -C "$SHELLSMITH_WORKSPACE" config submodule.recurse true
}

create_launch_script() {
  rm -f "$SHELLSMITH_LAUNCH"
  cat >"$SHELLSMITH_LAUNCH" <<EOF
#!/usr/bin/env bash
export SHELLSMITH_WORKSPACE="$SHELLSMITH_WORKSPACE"
export SHELLSMITH_DOTFILES="$SHELLSMITH_DOTFILES"
export SHELLSMITH_APPS="$SHELLSMITH_APPS"
export SHELLSMITH_MISC="$SHELLSMITH_MISC"
export SHELLSMITH_UTILS="$SHELLSMITH_UTILS"
"$SHELLSMITH_ROOT/cli.sh" "\$@"
EOF
  chmod +x "$SHELLSMITH_LAUNCH"
  echo "Launch script created at $SHELLSMITH_LAUNCH"
}

verify_submodule
update_submodules
enable_merge_workflow

create_launch_script || echo "Error: Failed to create launch script." >&2 && exit 1

echo "ShellSmith installed successfully at $SHELLSMITH_ROOT. Run 'smith help' to get started."
