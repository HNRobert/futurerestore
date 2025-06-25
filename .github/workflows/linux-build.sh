#!/usr/bin/env bash

set -e
export TMPDIR=/tmp
export WORKFLOW_ROOT=${TMPDIR}/Builder/repos/futurerestore/.github/workflows
export DEP_ROOT=${TMPDIR}/Builder/repos/futurerestore/dep_root
export BASE=${TMPDIR}/Builder/repos/futurerestore/

cd ${BASE}
# Check if we have static dependencies or need to use system packages
if [ -d "${DEP_ROOT}/Linux_x86_64_Release/lib" ] && [ -d "${DEP_ROOT}/Linux_x86_64_Release/include" ]; then
    echo "Using static dependencies"
    ln -sf ${DEP_ROOT}/Linux_x86_64_Release/{lib/,include/}  ${DEP_ROOT}/
    CMAKE_FLAGS="-DNO_PKGCFG=ON"
else
    echo "Using system dependencies"
    CMAKE_FLAGS=""
fi
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_MAKE_PROGRAM=$(which make) -DCMAKE_C_COMPILER=$(which clang) -DCMAKE_MESSAGE_LOG_LEVEL="WARNING" -DCMAKE_CXX_COMPILER=$(which clang++) -G "CodeBlocks - Unix Makefiles" -S ./ -B cmake-build-release-x86_64 -DARCH=x86_64 -DCMAKE_C_COMPILER=clang-15 -DCMAKE_CXX_COMPILER=clang++-15 -DCMAKE_LINKER=ld.lld-15 ${CMAKE_FLAGS}
make -j4 -l4 -C cmake-build-release-x86_64

cd ${BASE}
if [ -d "${DEP_ROOT}/Linux_x86_64_Debug/lib" ] && [ -d "${DEP_ROOT}/Linux_x86_64_Debug/include" ]; then
    echo "Using static dependencies for Debug build"
    ln -sf ${DEP_ROOT}/Linux_x86_64_Debug/{lib/,include/} ${DEP_ROOT}/
    CMAKE_FLAGS="-DNO_PKGCFG=ON"
else
    echo "Using system dependencies for Debug build"
    CMAKE_FLAGS=""
fi
cmake -DCMAKE_BUILD_TYPE=Debug -DCMAKE_MAKE_PROGRAM=$(which make) -DCMAKE_C_COMPILER=$(which clang) -DCMAKE_CXX_COMPILER=$(which clang++) -DCMAKE_MESSAGE_LOG_LEVEL="WARNING" -G "CodeBlocks - Unix Makefiles" -S ./ -B cmake-build-debug-x86_64 -DARCH=x86_64 -DCMAKE_C_COMPILER=clang-15 -DCMAKE_CXX_COMPILER=clang++-15 -DCMAKE_LINKER=ld.lld-15 ${CMAKE_FLAGS}
make -j4 -l4 -C cmake-build-debug-x86_64

cd ${BASE}
if [ -d "${DEP_ROOT}/Linux_x86_64_Debug/lib" ] && [ -d "${DEP_ROOT}/Linux_x86_64_Debug/include" ]; then
    echo "Using static dependencies for ASAN build"
    ln -sf ${DEP_ROOT}/Linux_x86_64_Debug/{lib/,include/} ${DEP_ROOT}/
    CMAKE_FLAGS="-DNO_PKGCFG=ON -DASAN=ON"
else
    echo "Using system dependencies for ASAN build"
    CMAKE_FLAGS="-DASAN=ON"
fi
cmake -DCMAKE_BUILD_TYPE=Debug -DCMAKE_MAKE_PROGRAM=$(which make) -DCMAKE_C_COMPILER=$(which clang) -DCMAKE_CXX_COMPILER=$(which clang++) -DCMAKE_MESSAGE_LOG_LEVEL="WARNING" -G "CodeBlocks - Unix Makefiles" -S ./ -B cmake-build-asan-x86_64 -DARCH=x86_64 -DCMAKE_C_COMPILER=clang-15 -DCMAKE_CXX_COMPILER=clang++-15 -DCMAKE_LINKER=ld.lld-15 ${CMAKE_FLAGS}
make -j4 -l4 -C cmake-build-asan-x86_64

llvm-strip-15 -s cmake-build-release-x86_64/src/futurerestore
