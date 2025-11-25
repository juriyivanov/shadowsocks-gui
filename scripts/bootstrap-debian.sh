#!/usr/bin/env bash
set -euo pipefail

# This script provisions a fresh Debian machine with all dependencies
# required to build the Shadowsocks GUI application. It installs the
# build toolchain, clones a QtShadowsocks fork and the application
# repository, and then performs a Release build.

# Configuration (can be overridden via environment variables).
# QSS_REPO should point to a Qt 6 compatible QtShadowsocks fork.
WORKDIR=${WORKDIR:-$PWD/shadowsocks-gui}
SHADOWSOCKS_GUI_REPO=${SHADOWSOCKS_GUI_REPO:-https://github.com/juriyivanov/shadowsocks-gui.git}
QSS_REPO=${QSS_REPO:-https://github.com/shadowsocks/libQtShadowsocks.git}
QSS_BRANCH=${QSS_BRANCH:-master}
QSS_BUILD_DIR=${QSS_BUILD_DIR:-/tmp/qtshadowsocks-build}

# Use sudo only when necessary
if [ "${EUID}" -ne 0 ]; then
    SUDO=sudo
else
    SUDO=""
fi

info() { printf "\n[%s] %s\n" "$(date -Iseconds)" "$*"; }

info "Updating APT index and installing build dependencies"
$SUDO env DEBIAN_FRONTEND=noninteractive apt-get update
$SUDO env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    git ca-certificates build-essential cmake ninja-build pkg-config \
    qt6-base-dev qt6-base-dev-tools qt6-tools-dev qt6-tools-dev-tools \
    qtbase5-dev qtbase5-dev-tools qttools5-dev qttools5-dev-tools qt5-qmake \
    libqrencode-dev libzbar-dev libbotan-2-dev

info "Cloning QtShadowsocks from ${QSS_REPO} (branch: ${QSS_BRANCH})"
rm -rf "${QSS_BUILD_DIR}"
git clone --depth=1 --branch "${QSS_BRANCH}" "${QSS_REPO}" "${QSS_BUILD_DIR}"

info "Configuring and building QtShadowsocks"
cmake -S "${QSS_BUILD_DIR}" -B "${QSS_BUILD_DIR}/build" \
    -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr/local \
    -DQt5_DIR=/usr/lib/x86_64-linux-gnu/cmake/Qt5
cmake --build "${QSS_BUILD_DIR}/build" --parallel
$SUDO cmake --install "${QSS_BUILD_DIR}/build"

info "Cloning Shadowsocks GUI into ${WORKDIR}"
rm -rf "${WORKDIR}"
git clone "${SHADOWSOCKS_GUI_REPO}" "${WORKDIR}"

info "Configuring and building Shadowsocks GUI"
cmake -S "${WORKDIR}" -B "${WORKDIR}/build" -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build "${WORKDIR}/build" --parallel

info "Done. Binaries are in ${WORKDIR}/build"
