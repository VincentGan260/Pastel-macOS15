#!/bin/sh
# Generate a signed fork-only Sparkle feed for a DMG hosted in GitHub Releases.
set -eu
project_root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
derived_data=${PASTEL_DERIVED_DATA:-"${TMPDIR:-/tmp}/PastelDistributionDerivedData"}
tools=${SPARKLE_TOOLS_DIR:-"${derived_data}/SourcePackages/artifacts/sparkle/Sparkle/bin"}
account=Pastel-macOS15-VincentGan260
archive=${1:?Usage: GenerateUpdateFeed.sh /absolute/path/to/Pastel.dmg [/path/to/Pastel.app]}
app=${2:-"${derived_data}/Build/Products/Release/Pastel.app"}
archive_name=$(basename "$archive")
version=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$app/Contents/Info.plist")
build=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$app/Contents/Info.plist")
expected_name="Pastel-${version}-build-${build}.dmg"
if [ "$archive_name" != "$expected_name" ]; then
    echo "Archive name must match the application version: ${expected_name}" >&2
    exit 1
fi
public_key=$("$tools/generate_keys" --account "$account" -p)
embedded_key=$(/usr/libexec/PlistBuddy -c 'Print :SUPublicEDKey' "$app/Contents/Info.plist")
if [ "$public_key" != "$embedded_key" ]; then
    echo "Signing key does not match the application's fork update key." >&2
    exit 1
fi
codesign --verify --deep --strict "$app"
release_url="https://github.com/VincentGan260/Pastel-macOS15/releases/tag/macOS15-${version}"
download_url="https://github.com/VincentGan260/Pastel-macOS15/releases/download/macOS15-${version}/"
staging=$(mktemp -d "${TMPDIR:-/tmp}/pastel-appcast.XXXXXX")
trap 'rm -rf "$staging"' EXIT HUP INT TERM
cp "$archive" "$staging/$archive_name"
notes="${project_root}/release-notes/${version}/release-notes.md"
if [ -f "$notes" ]; then
    cp "$notes" "$staging/${archive_name%.dmg}.txt"
fi
"$tools/generate_appcast" --account "$account" \
    --versions "$build" --maximum-deltas 0 --maximum-versions 1 \
    --download-url-prefix "$download_url" --embed-release-notes \
    --link "$release_url" -o "$staging/appcast.xml" "$staging"
signature=$(/usr/bin/xmllint --xpath 'string(//enclosure/@*[local-name()="edSignature"])' "$staging/appcast.xml")
test -n "$signature"
"$tools/sign_update" --account "$account" --verify "$archive" "$signature"
"$tools/sign_update" --account "$account" --verify "$staging/appcast.xml"
cp "$staging/appcast.xml" "${project_root}/appcast.xml"
echo "Signed feed: ${project_root}/appcast.xml"
echo "Release must contain: $download_url$archive_name"
echo "Publish the Release assets before pushing this feed to main."
