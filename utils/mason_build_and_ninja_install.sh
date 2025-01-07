#!/usr/bin/env bash

error_exit() {
  echo "$1" >&2
  exit 1
}

prepare_dir() {
  local path=$1
  rm -rf "$path"
  mkdir -p "$path" || error_exit "Failed to create directory $path"
}

clone_repo() {
  local url="$1"
  local tag="$2"
  local path="$3"

  git clone --recurse-submodules "$url" "$path" || error_exit "$path: Git clone failed"
  [ -n "$tag" ] && git -C "$path" checkout "$tag" || error_exit "$path: Failed to checkout tag $tag"
  git -C "$path" submodule update --init --recursive || error_exit "$path: Failed to update submodules"
}

prepare_project() {
  local repo="$1"
  local base_dir="$2"
  local project_type="$3" # "main" or "subproject"

  local repo_url=$(echo "$repo" | awk '{print $1}')
  local repo_tag=$(echo "$repo" | awk '{print $2}')
  local repo_name=$(basename -s .git "$repo_url")
  local project_dir="$base_dir/$repo_name"

  prepare_dir "$project_dir"
  clone_repo "$repo_url" "$repo_tag" "$project_dir"

  [ "$project_type" == "main" ] && echo "$project_dir"
}

build_and_install() {
  local repos=("$@")
  local main_repo="${repos[0]}"
  local sub_repos=("${repos[@]:1}")
  local build_dir="$HOME/build"

  local main_dir=$(prepare_project "$main_repo" "$build_dir" "main")

  local subprojects_dir="$main_dir/subprojects"
  prepare_dir "$subprojects_dir"

  for repo in "${sub_repos[@]}"; do
    prepare_project "$repo" "$subprojects_dir" "subproject"
  done

  [ ! -f "$main_dir/meson.build" ] && error_exit "$main_dir: meson.build file not found"

  meson setup "$main_dir/build" "$main_dir" --prefix=/usr/local || error_exit "Meson setup failed for $main_dir"
  ninja -C "$main_dir/build" -j2 || error_exit "Build failed for $main_dir"
}

meson_build_and_ninja_install "$@"
