#!/bin/sh

set -e

cd "$(dirname "$0")"
swift build -c release --target DebugMenuKitMacrosTests -Xswiftc -Osize
bin_path_root=$(swift build -c release --target DebugMenuKitMacrosTests --show-bin-path)
binary=$(find "${bin_path_root}" -name "DebugMenuKitMacros-tool" -type f -not -path "*.dSYM*" | head -n 1)

if [ -z "${binary}" ]; then
    binary=$(find "${bin_path_root}" -name "DebugMenuKitMacros" -type f -not -path "*.dSYM*" | head -n 1)
fi

if [ -z "${binary}" ]; then
    echo "Error: DebugMenuKitMacros executable not found in ${bin_path_root}"
    exit 1
fi

mkdir -p Prebuilt
cp "${binary}" Prebuilt/DebugMenuKitMacros
chmod u+x Prebuilt/DebugMenuKitMacros
strip -x Prebuilt/DebugMenuKitMacros
echo "Built Prebuilt/DebugMenuKitMacros"
