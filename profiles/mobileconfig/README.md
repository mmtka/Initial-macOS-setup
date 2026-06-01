# Configuration profiles (`.mobileconfig`)

Drop your `.mobileconfig` files in this folder. `tui.sh` / `bootstrap.sh`
auto-discover them and open each one for approval.

These files are **git-ignored on purpose** — profiles frequently embed personal
data (DNS query tokens, device names, signing certificates), so they should not
land in a public repo. Keep them here locally, or point `PROFILES_DIR` in
`config.sh` at another location (e.g. a NAS folder).

## Important on macOS 26+

Apple removed `profiles install`. A profile **cannot** be installed silently from
the command line without MDM. The setup `open`s each profile; you then approve it
in **System Settings ▸ General ▸ Device Management**.

## Scripts win over profiles

Managed profiles override `defaults write` (`mcxdomain = always`). This repo
treats the **shell scripts as the source of truth**, so profiles that manage a
domain a script also sets (Finder, Dock, Safari, global prefs) are handled
automatically:

- they are **detected as conflicting** and **never installed**;
- their already-installed copies are **removed** before defaults are applied
  (`REMOVE_CONFLICTING_PROFILES=true` in `config.sh`, uses sudo). Removal is
  surgical — only profiles touching those domains are removed.

Use this folder for settings the scripts can't express, e.g. **AdGuard DNS**
(`com.apple.dnsSettings`).

## The Gatekeeper exception

`gatekeeper.mobileconfig` is intentionally **installed and kept**. On macOS 26
(Tahoe) `spctl --master-disable` is gone, so disabling Gatekeeper assessment
(`com.apple.systempolicy.control` → `EnableAssessment = false`) is only possible
via a profile. It is therefore *not* treated as a conflict and *not* removed.
Delete the file if you want Gatekeeper to stay fully enabled.
