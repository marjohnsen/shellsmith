#!/usr/bin/env bash

set -e

SELECTED_APPS=""
RESOLVED_APPS=""

source "$SHELLSMITH_ROOT/app/app_handler.sh" || exit 1
source "$SHELLSMITH_ROOT/app/dependency_handler.sh" || exit 1
source "$SHELLSMITH_ROOT/app/app_installer.sh" || exit 1

if [[ ! -d "$SHELLSMITH_WORKSPACE/apps" ]]; then
  echo "Error: Apps directory '$SHELLSMITH_WORKSPACE/apps' is missing."
  echo "Please create a valid workspace."
  exit 1
fi

app_handler

if [[ -z "$SELECTED_APPS" ]]; then
  echo "No applications were selected. Exiting..."
  exit 1
fi

dependency_handler "$SELECTED_APPS"
app_installer "$RESOLVED_APPS"
