#!/bin/bash

set -e
set -o pipefail

safe_symlink() {
  local source="$1"
  local dest="$2"

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    while true; do
      read -p "File $dest exists. Overwrite? [y/n/a]: " choice
      case "$choice" in
      y | Y)
        rm -rf "$dest"
        ln -s "$source" "$dest"
        break
        ;;
      n | N)
        echo "Skipping $dest."
        return 0
        ;;
      a | A)
        echo "Aborting installation."
        exit 1
        ;;
      *)
        echo "Invalid choice. Please enter y (yes), n (no), or a (abort)."
        ;;
      esac
    done
  else
    ln -s "$source" "$dest"
  fi
}
