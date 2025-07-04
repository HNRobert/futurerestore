#!/usr/bin/env bash

set -e
export TMPDIR=/tmp
export WORKFLOW_ROOT=${TMPDIR}/Builder/repos/futurerestore/.github/workflows
export DEP_ROOT=${TMPDIR}/Builder/repos/futurerestore/dep_root
export BASE=${TMPDIR}/Builder/repos/futurerestore/

#sed -i 's/deb\.debian\.org/ftp.de.debian.org/g' /etc/apt/sources.list
apt-get -qq update
apt-get -yqq dist-upgrade
apt-get install --no-install-recommends -yqq zstd curl gnupg2 lsb-release wget software-properties-common build-essential git autoconf automake libtool-bin pkg-config cmake zlib1g-dev libminizip-dev libpng-dev libreadline-dev libbz2-dev libudev-dev libudev1
cp -RpP /usr/bin/ld /
rm -rf /usr/bin/ld /usr/lib/x86_64-linux-gnu/lib{usb-1.0,png*,readline}.so*
chown -R 0:0 ${BASE}
cd ${BASE}
ls -lath
git submodule update --init --recursive
cd ${WORKFLOW_ROOT}
curl -sO https://apt.llvm.org/llvm.sh
chmod +x llvm.sh
./llvm.sh 15 all
ln -sf /usr/bin/ld.lld-15 /usr/bin/ld
ln -sf /usr/bin/clang-15 /usr/bin/clang
ln -sf /usr/bin/clang++-15 /usr/bin/clang++
curl -sO https://cdn.cryptiiiic.com/bootstrap/linux_fix.tar.zst &
curl -sO https://cdn.cryptiiiic.com/deps/static/Linux/x86_64/Linux_x86_64_Release_Latest.tar.zst &
curl -sO https://cdn.cryptiiiic.com/deps/static/Linux/x86_64/Linux_x86_64_Debug_Latest.tar.zst &
curl -sLO https://github.com/Kitware/CMake/releases/download/v3.23.2/cmake-3.23.2-linux-x86_64.tar.gz &
wait
# Check if dependency files were downloaded successfully
if [ ! -f "Linux_x86_64_Release_Latest.tar.zst" ]; then
    echo "Error: Failed to download Linux_x86_64_Release_Latest.tar.zst"
    echo "Installing dependencies via apt instead..."
    apt-get install --no-install-recommends -yqq libplist-dev libimobiledevice-dev libusbmuxd-dev libimobiledevice-glue-dev libirecovery-dev libzip-dev libssl-dev libcurl4-openssl-dev
fi
rm -rf ${DEP_ROOT}/{lib,include} || true
mkdir -p ${DEP_ROOT}/Linux_x86_64_{Release,Debug}
if [ -f "Linux_x86_64_Release_Latest.tar.zst" ]; then
    tar xf Linux_x86_64_Release_Latest.tar.zst -C ${DEP_ROOT}/Linux_x86_64_Release &
fi
if [ -f "Linux_x86_64_Debug_Latest.tar.zst" ]; then
    tar xf Linux_x86_64_Debug_Latest.tar.zst -C ${DEP_ROOT}/Linux_x86_64_Debug &
fi
if [ -f "linux_fix.tar.zst" ]; then
    tar xf linux_fix.tar.zst -C ${TMPDIR}/Builder &
fi
echo "Installing CMake 3.23.2..."
tar xf cmake-3.23.2-linux-x86_64.tar.gz
# Install CMake to a specific location and update PATH
mkdir -p /usr/local/cmake
cp -RpP cmake-3.23.2-linux-x86_64/* /usr/local/cmake/ || true
# Make sure new cmake is in PATH
export PATH="/usr/local/cmake/bin:$PATH"
echo "CMake version check:"
/usr/local/cmake/bin/cmake --version
# Create symlink to ensure cmake command works
ln -sf /usr/local/cmake/bin/cmake /usr/local/bin/cmake
wait
rm -rf *.zst *.gz cmake-* llvm.sh
cd ${WORKFLOW_ROOT}
