#!/bin/sh
set -ex

# https://apple.stackexchange.com/questions/59556/is-there-a-way-to-completely-disable-dock
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 5
defaults write com.apple.dock no-bouncing -bool TRUE

# https://nikitabobko.github.io/AeroSpace/guide#a-note-on-mission-control
# https://nikitabobko.github.io/AeroSpace/guide#a-note-on-displays-have-separate-spaces
defaults write com.apple.dock expose-group-apps -bool true
defaults write com.apple.spaces spans-displays -bool true

# https://frida.re/news/2020/07/24/frida-12-11-released/
sudo nvram boot-args="-arm64e_preview_abi"

xcode-select --install

# https://brew.sh/
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# https://github.com/DeterminateSystems/nix-installer
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
