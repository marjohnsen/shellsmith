#!/bin/bash

pushd "$(dirname "${BASH_SOURCE[0]}")" || exit 1
trap 'popd' EXIT ERR INT TERM HUP

source ./src/app_handler.sh
source ./src/dependency_handler.sh
source ./src/install_handler.sh

APPS=()
app_handler APPS

if [[ "${#APPS[@]}" -eq 0 ]]; then
  echo "No applications were selected. Exiting..."
  exit 1
fi

dependency_handler APPS
install_handler "${APPS[@]}"
