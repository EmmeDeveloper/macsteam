# Contributing

This fork is maintained actively. Open or pick an [issue](https://github.com/EmmeDeveloper/macsteam/issues) first, then send a PR against `main`.

## Build and test

```bash
make rebuild                 # the dylib -> out/macsteam.dylib
cd macsteam-app
swift test                   # unit tests (Lua parser, diagnostics)
bash make_app.sh             # the config app
```

CI (`.github/workflows/app.yml`) runs the same steps on `macos-15`.

## Supporting a new Steam build

macSteam pins the Steam client to one build (`MacCrab.supportedVersion` in
`macsteam-app/Sources/MacsteamApp/MacCrab.swift`). To move to a new build:

1. Add the build's signature file in `signatures/macos.arm64/<build>.json`.
2. Update `MacCrab.supportedVersion` and, if the resolver needs it, `src/resolver/`.
3. Bump the version in `src/version.h` and in `macsteam-app/make_app.sh`
   (`CFBundleShortVersionString` and `CFBundleVersion`).
4. Add an entry to `CHANGELOG.md`.

## Releasing

Run the **Release** workflow (Actions tab) with the version, e.g. `0.8.4`. It builds the dylib and
the app, packages `macSteam-<version>.dmg` and creates the GitHub release.

## PR guidelines

- One concern per PR, with a description of what and why.
- Include a test when you touch parsing logic (`macsteam-app/Tests`).
- Keep the GPL license and copyright headers; credit upstream where code comes from it.
- Never commit depot keys or personal paths.

## Manifest and Steam UI regression checks

```bash
make test                     # offline C probes and Swift unit tests
make test-manifest-live        # three real HTTPS provider requests
make test-ui STEAM_BUNDLE=/absolute/path/to/pristine/sp.js
bash scripts/test_localization.sh
```

UI checks work on temporary copies and leave the installed Steam client alone.
Without `STEAM_BUNDLE`, `make test-ui` downloads Valve’s current bundle to a local
cache. It checks syntax, unchanged byte length, Cloud toggle restoration, unknown
bundle fallback, and repeated launches with both UI patches together.
The live provider check confirms request-code delivery; a complete download still
requires a manual Steam test with the needed depot keys and authorization.

These features adapt upstream PRs [#3](https://github.com/crghofficial/macsteam/pull/3),
[#6](https://github.com/crghofficial/macsteam/pull/6),
[#2](https://github.com/crghofficial/macsteam/pull/2), and
[#5](https://github.com/crghofficial/macsteam/pull/5) by ElfariaKensington.
