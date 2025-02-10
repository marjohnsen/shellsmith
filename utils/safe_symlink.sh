#!/usr/bin/env bash

safe_symlink() {
  local source="$1"
  local dest="$2"

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    while true; do
      read -p "File $dest exists. Overwrite? [y/n/a]: " choice
      case "$choice" in
      ^[Yy]([Ee][Ss])?$)
        rm -rf "$dest"
        ln -s "$source" "$dest"
        echo "Overwritten: '$dest'"
        break
        ;;
      ^[Nn]([Oo])?$)
        echo "Not overwritten: '$dest'"
        return 0
        ;;
      ^[Aa]([Bb][Oo][Rr][Tt])?$)
        echo "Aborted."
        exit 1
        ;;
      *)
        echo "Invalid choice. Use [y/n/a]."
        ;;
      esac
    done
  else
    ln -s "$source" "$dest"
    echo "Created: '$dest' -> '$source'"
  fi
}
