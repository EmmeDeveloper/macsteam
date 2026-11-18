# Changelog

All notable changes to this fork. Releases: https://github.com/EmmeDeveloper/macsteam/releases

## Unreleased

- HTTPS manifest request-code provider with strict HTTP and uint64 response validation (#9; upstream PR #3 by ElfariaKensington).
- Managed launches refresh the cached source ownership ticket, preserving native responses and restoring IPC packets (#10; upstream PR #6 by ElfariaKensington).
- Optional, reversible Steam Cloud error UI toggle, default off; English and Simplified Chinese labels (#11; upstream PR #2 by ElfariaKensington).
- Hide shared-library owner and retirement-notice rows at startup; preserve Cloud recovery across launches (#12; upstream PR #5 by ElfariaKensington).
- Regression checks for manifest responses, ticket routing, UI patch compatibility, and settings persistence.

- Simplified Chinese localization (upstream PR #7 by KameraZhao).
- Warning when an imported .lua has no depot keys.
- Settings: Copy Diagnostics for bug reports.
- Unit tests and `swift test` in CI.
- Removed Sparkle auto-update; the app menu and the sidebar link open the GitHub releases page.
- Sidebar shows the app version and the supported Steam build.

## 0.8.3

- Support Steam build 1794536281 (new signature).
- Fresh installs pin the Steam client to the supported build before Steam's first launch (fetches Valve's manifest, refuses if Valve's current build isn't supported).

## 0.8.2 (upstream, crghofficial/macsteam)

- Support Steam build 1792618285.
- Anchor-based signature resolution survives Steam updates.
