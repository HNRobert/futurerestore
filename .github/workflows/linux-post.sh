#!/usr/bin/env bash

set -e
export TMPDIR=/tmp
export WORKFLOW_ROOT=${TMPDIR}/Builder/repos/futurerestore/.github/workflows
export DEP_ROOT=${TMPDIR}/Builder/repos/futurerestore/dep_root
export BASE=${TMPDIR}/Builder/repos/futurerestore/

cd ${BASE}
export FUTURERESTORE_VERSION=$(git rev-list --count HEAD | tr -d '\n')
export FUTURERESTORE_VERSION_RELEASE=$(cat version.txt | tr -d '\n')
cd ${WORKFLOW_ROOT}
echo "futurerestore-Linux-x86_64-${FUTURERESTORE_VERSION_RELEASE}-Build_${FUTURERESTORE_VERSION}-RELEASE.tar.xz" >name1.txt
echo "futurerestore-Linux-x86_64-${FUTURERESTORE_VERSION_RELEASE}-Build_${FUTURERESTORE_VERSION}-DEBUG.tar.xz" >name2.txt
echo "futurerestore-Linux-x86_64-${FUTURERESTORE_VERSION_RELEASE}-Build_${FUTURERESTORE_VERSION}-ASAN.tar.xz" >name3.txt
if [ -f "${TMPDIR}/Builder/linux_fix.sh" ]; then
    cp -RpP "${TMPDIR}/Builder/linux_fix.sh" linux_fix.sh
fi
if [ -f "${BASE}/cmake-build-release-x86_64/src/futurerestore" ]; then
    cp -RpP "${BASE}/cmake-build-release-x86_64/src/futurerestore" futurerestore
    if [ -f "linux_fix.sh" ]; then
        tar cpPJvf "futurerestore1.tar.xz" futurerestore linux_fix.sh
    else
        tar cpPJvf "futurerestore1.tar.xz" futurerestore
    fi
else
    echo "Error: Release build failed, futurerestore binary not found"
    exit 1
fi
if [ -f "${BASE}/cmake-build-debug-x86_64/src/futurerestore" ]; then
    cp -RpP "${BASE}/cmake-build-debug-x86_64/src/futurerestore" futurerestore
    if [ -f "linux_fix.sh" ]; then
        tar cpPJvf "futurerestore2.tar.xz" futurerestore linux_fix.sh
    else
        tar cpPJvf "futurerestore2.tar.xz" futurerestore
    fi
else
    echo "Error: Debug build failed, futurerestore binary not found"
    exit 1
fi
if [ -f "${BASE}/cmake-build-asan-x86_64/src/futurerestore" ]; then
    cp -RpP "${BASE}/cmake-build-asan-x86_64/src/futurerestore" futurerestore
    if [ -f "linux_fix.sh" ]; then
        tar cpPJvf "futurerestore3.tar.xz" futurerestore linux_fix.sh
    else
        tar cpPJvf "futurerestore3.tar.xz" futurerestore
    fi
else
    echo "Error: ASAN build failed, futurerestore binary not found"
    exit 1
fi
