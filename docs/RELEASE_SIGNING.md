# macOS 15 community fork signing

This fork continues to use ad-hoc signing, matching its previous releases.
`Scripts/BuildAdHocDMG.sh` defaults to `PASTEL_SIGNING_IDENTITY=-` and verifies
all nested signatures, Node JIT execution, and the host signature. It does not
enable Hardened Runtime on the host, which must load Sparkle without a Team ID.
The app is not notarized. macOS may ask users to approve it and reauthorize
Keychain access after updating.

A maintainer with a stable signing identity may pass `PASTEL_SIGNING_IDENTITY`.
The verifier rejects a missing named identity. Do not generate or replace an
existing signing certificate for an ordinary update.

The following describes the upstream project's separate identity; its private
key is not included in this fork and is not required to build this fork.

---

# Pastel release signing

`Scripts/BuildAdHocDMG.sh` now builds locally without an Apple Developer account
or certificate. It applies ad-hoc signatures (`codesign --sign -`) required to
run the bundled arm64 executables and their JIT entitlements. The script signs
nested executables first and the app last, verifies the bundle, and creates a
DMG. These signatures are local runtime signatures, not Developer ID notarization.

Run from the repository root:

```sh
sh Scripts/BuildAdHocDMG.sh
```

A configured stable self-signed identity remains optional:

```sh
PASTEL_SIGNING_IDENTITY="Pastel Release Signing" sh Scripts/BuildAdHocDMG.sh
```

A stable identity can retain the same Keychain designated requirement across
updates. Switching signing identities may require authorizing Keychain access
again. The build never deletes the vault or replaces its encryption key.

For a Mac which previously used that optional identity, its encrypted PKCS#12
backup is outside the repository at
`~/Documents/Pastel Release Signing Backup/Pastel Release Signing.p12`.
The backup password is in the login Keychain under service
`com.eeliberto.pastel.release-signing-backup-password` and account
`Pastel Release Signing`. Do not commit or bundle the private key or backup.

Sparkle's EdDSA update signature is separate from local code signing. This local
build script does not publish an update or change the appcast.
