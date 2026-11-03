# macOS 15 fork updates

The app checks the signed feed at:

https://raw.githubusercontent.com/VincentGan260/Pastel-macOS15/main/appcast.xml

The feed references DMGs in this fork's GitHub Releases. It contains no upstream
release entries. Sparkle verifies the feed and the download with the fork's
Ed25519 public key in `Pastel/Info.plist`, then downloads and installs in-app.
Automatic checks run daily by default. Users can change automatic checking and
downloading in Settings → About; their choices persist across launches.

The private key is stored only in the build Mac's login Keychain, under the
Sparkle account `Pastel-macOS15-VincentGan260`. Never commit it, publish it in a
Release, or generate a replacement during ordinary updates. Restore the same
key on a replacement build Mac using Sparkle's `generate_keys` import/export
commands and a secure private backup. The public key is safe to commit.

## Publishing

1. Increase both `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` in the project.
   Create `release-notes/<version>/release-notes.md`.
2. Run `sh Scripts/BuildAdHocDMG.sh`. Validate the app and DMG.
3. Run the feed generator using the same build directory:

   ```sh
   PASTEL_DERIVED_DATA=/tmp/PastelDistributionDerivedData \
     sh Scripts/GenerateUpdateFeed.sh \
     "$PWD/dist/Pastel-<version>-build-<build>.dmg"
   ```

   Set `SPARKLE_TOOLS_DIR` if Sparkle's tools are in a different directory.
   This verifies the key matches the app, signs the DMG and feed, verifies both,
   and replaces `appcast.xml`. Do not edit the signed XML afterwards.
4. Commit the source changes, including the signed `appcast.xml`. Create a GitHub
   Release with tag `macOS15-<version>` targeting that full commit hash, upload the
   exact signed DMG and its SHA-256 file, and publish it. Confirm the assets are
   available. Then push the commit to `main`, so existing users see the new feed
   only after the referenced download exists. A Release target can be pushed to
   a temporary branch before publishing if the commit is not yet on GitHub.
5. Verify the public feed matches the signed local file and the Release asset's
   SHA-256 matches the local DMG. Keep the matching signing key for future updates.

This order avoids offering downloads that have not been uploaded. GitHub may
cache raw feed responses briefly. Never replace an existing version's DMG
without regenerating its signature and feed. Prefer a new build and Release.

## First installation

20261102 and older fork builds have automatic updating disabled and do not know
this key. Users must manually install 20261102.1 once. That version and later
can receive signed updates from this fork. Ad-hoc code signing and Gatekeeper
approval remain separate from Sparkle's update signature; these packages are
not Apple-notarized.
