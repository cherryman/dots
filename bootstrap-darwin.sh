#!/bin/sh
set -ex

# some tools implicitly require command line tools
xcode-select --install

# change screenshot location away from desktop
# falls back to desktop if dir doesn't exist lmfao
mkdir -p "$HOME/Pictures/screenshots"
defaults write com.apple.screencapture location "$HOME/Pictures/screenshots"

# https://frida.re/news/2020/07/24/frida-12-11-released/
sudo nvram boot-args="-arm64e_preview_abi"

# https://brew.sh/
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# https://github.com/DeterminateSystems/nix-installer
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
