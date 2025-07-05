#!/bin/sh
set -ex

# some tools implicitly require command line tools
xcode-select --install

# https://github.com/DeterminateSystems/nix-installer
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
