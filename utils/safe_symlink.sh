#!/usr/bin/env bash

safe_symlink() {
  local source="$1"
  local dest="$2"

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    while true; do
      read -r -p "File $dest exists. Overwrite? [y/n/a]: " choice </dev/tty
      if [[ "$choice" =~ ^[Yy]([Ee][Ss])?$ ]]; then
        rm -rf "$dest"
        ln -s "$source" "$dest"
        echo "Overwritten: '$dest'"
        break
      elif [[ "$choice" =~ ^[Nn]([Oo])?$ ]]; then
        echo "Not overwritten: '$dest'"
        return 0
      elif [[ "$choice" =~ ^[Aa]([Bb][Oo][Rr][Tt])?$ ]]; then
        echo "Aborted."
        exit 1
      else
        echo "Invalid choice. Use [y/n/a]."
      fi
    done
  else
    ln -s "$source" "$dest"
    echo "Created: '$dest' -> '$source'"
  fi
}
