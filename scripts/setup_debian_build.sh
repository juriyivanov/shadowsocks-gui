#!/usr/bin/env bash
set -euo pipefail

# This script bootstraps a fresh Debian system with all dependencies
# required to build the Shadowsocks GUI, then clones the repository and
# performs a Release build. It is intended for non-interactive use on
# a clean VM.

REPO_URL="${REPO_URL:-https://github.com/juriyivanov/shadowsocks-gui.git}"
CHECKOUT_DIR="${CHECKOUT_DIR:-$HOME/shadowsocks-gui}"
BUILD_TYPE="${BUILD_TYPE:-Release}"

if [[ $(id -u) -ne 0 ]]; then
    SUDO="sudo"
else
    SUDO=""
fi

info() {
    printf '\033[1;34m[INFO]\033[0m %s\n' "$*"
}

info "Updating apt indices..."
$SUDO apt-get update

info "Installing build dependencies..."
$SUDO apt-get install -y \
    git build-essential cmake pkg-config \
    qt6-base-dev qt6-base-dev-tools qt6-tools-dev qt6-tools-dev-tools libqt6svg6-dev \
    libqrencode-dev libzbar-dev libqtshadowsocks-dev

if [[ ! -d "$CHECKOUT_DIR" ]]; then
    info "Cloning repository into $CHECKOUT_DIR"
    git clone "$REPO_URL" "$CHECKOUT_DIR"
else
    info "Repository already exists at $CHECKOUT_DIR; pulling latest changes"
    git -C "$CHECKOUT_DIR" pull --ff-only
fi

cd "$CHECKOUT_DIR"

info "Configuring CMake (build type: $BUILD_TYPE)"
cmake -B build -S . -DCMAKE_BUILD_TYPE="$BUILD_TYPE"

info "Building project"
cmake --build build -j"$(nproc)"

info "Build completed successfully"
