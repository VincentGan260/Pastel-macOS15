#!/bin/sh
# Rebuild the upstream Store helper for the macOS 15 community fork.
set -eu
project_root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
go_bin=${GO_BIN:-go}
output=$(mktemp "${TMPDIR:-/tmp}/pastel-store-helper.XXXXXX")
trap 'rm -f "$output"' EXIT HUP INT TERM
cd "${project_root}/StoreHelper"
GOOS=darwin GOARCH=arm64 CGO_ENABLED=1 CGO_CFLAGS="-mmacosx-version-min=15.0" \
CGO_LDFLAGS="-mmacosx-version-min=15.0" MACOSX_DEPLOYMENT_TARGET=15.0 \
    "$go_bin" build -trimpath -ldflags='-linkmode=external -extldflags=-mmacosx-version-min=15.0' -o "$output" .
xcrun vtool -show-build "$output"
minimum=$(xcrun vtool -show-build "$output" | awk '$1 == "minos" {print $2}')
if [ "$minimum" != "15.0" ]; then
    echo "Unexpected Store helper deployment target: $minimum" >&2
    exit 1
fi
gzip -n -c "$output" > "${project_root}/node/bin/store-helper.gz"
echo "Rebuilt store-helper for macOS 15.0"
