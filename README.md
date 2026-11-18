# macsteam 

"Steam unlock client" for macOS. ARM macOS, specifically. **This does not support Intel Macs!**

> **This is my own work-in-progress project, started as a fork of [crghofficial/macsteam](https://github.com/crghofficial/macsteam)** (copyright Selectively11), whose last release was v0.8.2. I'm developing it on my own from there: it tracks new supported Steam builds, merges useful community PRs, and publishes its own releases. Credit for the original work goes to the upstream author. Work is tracked in [Issues](https://github.com/EmmeDeveloper/macsteam/issues). Auto-update (Sparkle) has been removed: get new versions from the [Releases page](https://github.com/EmmeDeveloper/macsteam/releases).

## Huh?

If you don't know what a Steam Unlock Client is, think 'SteamTools/OpenSteamTool/HubcapTools'. SLSSteam if you have good taste. If you don't know what those are, this isn't for you.

This is a minimal unlock client, at the moment. It supports game ownership spoofing ('unlocking') and license injection/downloading. It also has an achievement schema fetcher that is, umm, heavily 'inspired' by the one used in [SLSSteam](https://github.com/AceSLS/SLSsteam) but is no where as good or as well tested as that component was re-engineered hastily over the course of a few hours so that I could release.... 

Other than that one thing, this is an original work. It is _not_ a port of OpenSteamTool or SLSSteam to macOS. 

Manifest request codes are fetched from ManifestDeX over HTTPS as needed. This endpoint supplies request codes, not depot decryption keys. Invalid responses fall back to Steam’s original request-code handling.

## How?

1. The config app deploys a dylib 'into' the Steam app bundle. 
2. A dylib (`macsteam.dylib`) is injected into Steam on launch, which does the unlock work.

Pretty boring. 

What the config app changes on your machine:

- It copies `macsteam.dylib` into the Steam app bundle and sets `DYLD_INSERT_LIBRARIES` in its `Info.plist`.
- It writes `steam.cfg` (`BootStrapperInhibitUpdateOnLaunch=enable`) so Steam does not update itself to a build macSteam doesn't support.
- It writes its config and imported depot data under `~/Library/Application Support/macSteam` and `<Steam>/depotcache`.

The Repair pane in the config app handles re-deploying/fixing the install.

An imported `.lua` must contain the depot decryption keys (`addappid(<depot>, 1, "<key>")`); a script with only `addappid(<appid>)` will import but Steam will show 0 B and log `Missing decryption key`.

## macSteam Config

The companion app supports English and Simplified Chinese, following macOS's
preferred or per-app language. See [Localization](docs/LOCALIZATION.md) for
translation, packaging, and validation details.

The companion app can handle all the basics. It can deploy the macSteam dylib, it can import games, you can use it to remove games from your unlock list, you can toggle the features that support being toggled (with more to come). You can also edit the config by hand by going to ```~/Library/Application Support/macSteam``` and editing the config file.

## Steam UI options

**Hide Steam Cloud errors** in macSteam Settings defaults to off. When enabled,
it hides Cloud error indicators and notifications and continues past launch
warnings using Steam’s “play anyway” action. It does not disable Cloud syncing
or choose between local and remote saves. Restart Steam after changing the setting.
Turning it off restores the Cloud UI from a recovery copy matched to the patched
bundle’s SHA-256, so an older backup cannot overwrite a Steam update.
The config key is `HideCloudErrors: yes` (or `no`). Unknown bundle structures
are left unchanged and logged.

At startup macSteam also hides the “From the library of…” owner row and the
legacy library-sharing retirement notice. This UI patch is automatic and does
not change sharing permissions. Both UI patches preserve the JavaScript file’s
byte length and reapply to recognized bundles after an update. The sharing patch
runs before the Cloud patch so recovery copies remain valid across launches.

Managed game launches refresh the same source ownership ticket used by the
extended ticket getter, using Steam’s native cache and expiry handling. Malformed
or read-only IPC packets retain the original path.

## Usage

Download the latest release from the [Releases page](https://github.com/EmmeDeveloper/macsteam/releases).

Unzip it. Move macSteam Config to Applications. 

Go to Install, hit Install, let macSteam deploy. You will get a TCC prompt to allow macSteam to modify other applications, allow it.

## Building from source

The dylib:

```bash
make rebuild
```

The config app:

```bash
cd macsteam-app
bash make_app.sh
```

There is also a science experiment in the repo, a macSteam launcher that does not modify the Steam app bundle in any way. It is included for the enjoyment of others, but is not intended to be used. 

## Contributing

PRs are welcome. Check the [open issues](https://github.com/EmmeDeveloper/macsteam/issues) first.

## License

AGPLV2 with grifters being the reason why.
