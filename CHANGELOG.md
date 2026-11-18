# Changelog

All notable changes to this fork. Releases: https://github.com/EmmeDeveloper/macsteam/releases

## Unreleased

- Removed Sparkle auto-update; the app menu and the sidebar link open the GitHub releases page.
- Sidebar shows the app version and the supported Steam build.

## 0.8.3

- Support Steam build 1794536281 (new signature).
- Fresh installs pin the Steam client to the supported build before Steam's first launch (fetches Valve's manifest, refuses if Valve's current build isn't supported).

## 0.8.2 (upstream, crghofficial/macsteam)

- Support Steam build 1792618285.
- Anchor-based signature resolution survives Steam updates.
