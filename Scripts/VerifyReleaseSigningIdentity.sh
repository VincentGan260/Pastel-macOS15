#!/bin/sh
set -eu

# The macOS 15 community fork has always used ad-hoc signatures. A named
# identity remains supported for maintainers who have a stable certificate.
identity=${1:--}
if [ "$identity" = "-" ]; then
    echo "macOS 15 community fork: using ad-hoc signing (not notarized)."
    exit 0
fi

if ! security find-identity -v -p codesigning | grep -F -q "\"${identity}\""; then
    echo "Missing the stable '${identity}' code-signing identity." >&2
    echo "Refusing to create an Ad-hoc release because that would invalidate Keychain access." >&2
    exit 1
fi

echo "Stable release signing identity found: ${identity}"
