#!/bin/bash
# This file will always be executed first.
# Install basic stuff using package managers, install fonts, etc..

source utils/app_interface.sh

apt_install() {
  sudo apt update && sudo apt upgrade
}

apt_install
