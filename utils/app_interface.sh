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

meson_build_and_ninja_install() {
  local main_repo_info="$1"
  shift
  local build_path name repo_url git_tag

  setup_repo() {
    local url="$1"
    local tag="$2"
    local path="$3"
    git clone --recurse-submodules "$url" "$path" || error_exit "$path: Git clone failed"
    if [ -n "$tag" ]; then
      git -C "$path" checkout "$tag" || error_exit "$path: Failed to checkout tag $tag"
    fi
    git -C "$path" submodule update --init --recursive || error_exit "$path: Failed to update submodules"
  }

  main_repo_url=$(echo "$main_repo_info" | awk '{print $1}')
  main_git_tag=$(echo "$main_repo_info" | awk '{print $2}')
  name=$(basename -s .git "$main_repo_url" | tr '_' '-')
  build_path=~/build/"$name"

  cleanup_source_install "$name"
  prepare_build_dir "$build_path"
  setup_repo "$main_repo_url" "$main_git_tag" "$build_path"

  while [ $# -gt 0 ]; do
    repo_url=$(echo "$1" | awk '{print $1}')
    git_tag=$(echo "$1" | awk '{print $2}')
    subproject_path="$build_path/subprojects/$(basename -s .git "$repo_url" | tr '_' '-')"
    prepare_build_dir "$subproject_path"
    setup_repo "$repo_url" "$git_tag" "$subproject_path"
    shift
  done

  meson setup "$build_path/build" "$build_path" --prefix=/usr/local || error_exit "$name: Setup failed"
  ninja -C "$build_path/build" -j2 || error_exit "$name: Build failed"
  sudo ninja -C "$build_path/build" install -j2 || error_exit "$name: Install failed"
}
