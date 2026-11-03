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

Pastel releases must always be signed with the long-lived self-signed identity
named `Pastel Release Signing`. macOS uses this identity as part of Pastel's
designated requirement, which lets an updated build continue accessing the
same Keychain vault without repeatedly asking the user for their Mac password.

The encrypted PKCS#12 backup is stored outside this repository at:

`~/Documents/Pastel Release Signing Backup/Pastel Release Signing.p12`

Its password is stored in the login Keychain with service
`com.eeliberto.pastel.release-signing-backup-password` and account
`Pastel Release Signing`.

Never regenerate or replace this identity for an ordinary release. Losing it
means that existing users must authorize Keychain access again. Restore the
PKCS#12 backup into the login Keychain on a replacement build Mac.

`Scripts/BuildAdHocDMG.sh` refuses to build a distribution package when the
stable identity is missing. The script signs nested executables first and the
app last, then performs strict deep signature verification before creating the
DMG. Sparkle's EdDSA update signature remains a separate requirement.

The identity is self-signed, so it does not provide Developer ID notarization.
Users still need to approve the app through macOS when opening it for the first
time. The private key and backup must never be committed or shipped in the app.
