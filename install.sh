#!/usr/bin/env bash

set -e

SHELLSMITH_LAUNCH="$HOME/.local/bin/smith"
SHELLSMITH_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
SHELLSMITH_WORKSPACE="$(cd "$SHELLSMITH_ROOT/../" && pwd -P)"
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

create_launch_script() {
  rm -f "$SHELLSMITH_LAUNCH"
  cat >"$SHELLSMITH_LAUNCH" <<EOF
#!/usr/bin/env bash
export SHELLSMITH_ROOT="$SHELLSMITH_ROOT"
export SHELLSMITH_WORKSPACE="$SHELLSMITH_WORKSPACE"
export SHELLSMITH_DOTFILES="$SHELLSMITH_DOTFILES"
export SHELLSMITH_APPS="$SHELLSMITH_APPS"
export SHELLSMITH_MISC="$SHELLSMITH_MISC"
export SHELLSMITH_UTILS="$SHELLSMITH_UTILS"
"$SHELLSMITH_ROOT/cli.sh" "\$@"
EOF
  chmod +x "$SHELLSMITH_LAUNCH"
}

verify_submodule
create_launch_script

echo "ShellSmith has been successfully installed at '$SHELLSMITH_LAUNCH'."
echo "Run 'smith help' to get started."
