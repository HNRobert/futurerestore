#!/usr/bin/env zsh

set -e
export WORKFLOW_ROOT=/Users/runner/work/futurerestore/futurerestore/.github/workflows
export DEP_ROOT=/Users/runner/work/futurerestore/futurerestore/dep_root
export BASE=/Users/runner/work/futurerestore/futurerestore/

cd ${WORKFLOW_ROOT}
echo "Downloading dependencies..."
curl -sO https://cdn.cryptiiiic.com/bootstrap/bootstrap_x86_64.tar.zst &
curl -sO https://cdn.cryptiiiic.com/deps/static/macOS/x86_64/macOS_x86_64_Release_Latest.tar.zst &
curl -sO https://cdn.cryptiiiic.com/deps/static/macOS/arm64/macOS_arm64_Release_Latest.tar.zst &
curl -sO https://cdn.cryptiiiic.com/deps/static/macOS/x86_64/macOS_x86_64_Debug_Latest.tar.zst &
curl -sO https://cdn.cryptiiiic.com/deps/static/macOS/arm64/macOS_arm64_Debug_Latest.tar.zst &
wait
echo "Download complete. Checking downloaded files..."
# Check if all required files were downloaded successfully
REQUIRED_FILES=(
    "bootstrap_x86_64.tar.zst"
    "macOS_x86_64_Release_Latest.tar.zst"
    "macOS_arm64_Release_Latest.tar.zst"
    "macOS_x86_64_Debug_Latest.tar.zst"
    "macOS_arm64_Debug_Latest.tar.zst"
)
for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "Error: Failed to download $file"
        exit 1
    else
        echo "✓ $file downloaded successfully ($(ls -lh $file | awk '{print $5}'))"
    fi
done
sudo gtar xf ${WORKFLOW_ROOT}/bootstrap_x86_64.tar.zst -C / --warning=none || sudo tar xf ${WORKFLOW_ROOT}/bootstrap_x86_64.tar.zst -C / 2>/dev/null || true &
echo "${PROCURSUS}/bin" | sudo tee /etc/paths1
echo "${PROCURSUS}/libexec/gnubin" | sudo tee /etc/paths1
cat /etc/paths | sudo tee -a /etc/paths1
sudo mv /etc/paths{1,}
wait
rm -rf ${DEP_ROOT}/{lib,include} || true
mkdir -p ${DEP_ROOT}/macOS_x86_64_Release ${DEP_ROOT}/macOS_x86_64_Debug ${DEP_ROOT}/macOS_arm64_Release ${DEP_ROOT}/macOS_arm64_Debug
echo "Extracting dependency archives..."
gtar xf macOS_x86_64_Release_Latest.tar.zst -C ${DEP_ROOT}/macOS_x86_64_Release &
gtar xf macOS_x86_64_Debug_Latest.tar.zst -C ${DEP_ROOT}/macOS_x86_64_Debug &
gtar xf macOS_arm64_Release_Latest.tar.zst -C ${DEP_ROOT}/macOS_arm64_Release &
gtar xf macOS_arm64_Debug_Latest.tar.zst -C ${DEP_ROOT}/macOS_arm64_Debug &
wait
echo "Extraction complete. Verifying extracted directories..."
# Verify that extraction was successful
EXTRACT_DIRS=(
    "${DEP_ROOT}/macOS_x86_64_Release"
    "${DEP_ROOT}/macOS_x86_64_Debug"
    "${DEP_ROOT}/macOS_arm64_Release"
    "${DEP_ROOT}/macOS_arm64_Debug"
)
for dir in "${EXTRACT_DIRS[@]}"; do
    if [ ! -d "$dir/lib" ] || [ ! -d "$dir/include" ]; then
        echo "Error: Extraction failed for $dir - missing lib or include directory"
        exit 1
    else
        echo "✓ $dir extracted successfully"
        echo "  - lib: $(ls -1 $dir/lib | wc -l) files"
        echo "  - include: $(find $dir/include -name "*.h" | wc -l) header files"
    fi
done
sudo mv /usr/local/bin{,1}
cd ${BASE}
git submodule update --init --recursive
cd ${BASE}/external/tsschecker
git submodule update --init --recursive
