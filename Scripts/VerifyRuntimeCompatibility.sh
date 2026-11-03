#!/bin/sh
# Prevent upstream prebuilt executables from raising the fork's system minimum.
set -eu
app=$1
for executable in \
    "$app/Contents/MacOS/Pastel" \
    "$app/Contents/Resources/node/bin/node" \
    "$app/Contents/Resources/sap-signer" \
    "$app/Contents/Resources/store-helper"; do
    minimum=$(xcrun vtool -show-build "$executable" | awk '$1 == "minos" {print $2}')
    if ! printf '%s\n' "$minimum" | awk -F. 'NF >= 2 && ($1 < 15 || ($1 == 15 && $2 == 0)) {ok=1} END {exit !ok}'; then
        echo "Incompatible deployment target '${minimum}': ${executable}" >&2
        exit 1
    fi
    echo "macOS ${minimum}: ${executable}"
done
