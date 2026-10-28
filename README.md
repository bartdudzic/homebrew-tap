# Homebrew tap for Keep Mac Awake

[Keep Mac Awake](https://keepmacawake.com/?utm_source=github&utm_medium=community&utm_campaign=homebrew-tap) keeps your MacBook awake with the lid closed, without an external display or keyboard. This tap holds its Homebrew cask.

## Install

```sh
brew install --cask bartdudzic/tap/keepmacawake
```

The cask installs the release package from [bartdudzic/keepmacawake](https://github.com/bartdudzic/keepmacawake/releases), checked against its SHA-256. The package is signed with a Developer ID and notarized by Apple. macOS asks for your administrator password during installation, because the sleep setting applies to the whole Mac. It needs a Mac with Apple silicon and macOS 26 or later.

The app updates itself, so `brew upgrade` leaves it alone unless you pass `--greedy`.

## Uninstall

```sh
brew uninstall --cask keepmacawake
```

Like the uninstaller package of each release, it ends a running session, restores the sleep setting, stops the services and removes the app and the command. `brew uninstall --zap --cask keepmacawake` also removes your settings; after a reinstall, **Restore purchase** in the app brings a purchase back.

## About this tap

The cask is generated from the Keep Mac Awake repository at each release, so changes made here by hand are overwritten and pull requests are not accepted. Questions and bugs: [issues in bartdudzic/keepmacawake](https://github.com/bartdudzic/keepmacawake/issues). Everything else: hi@keepmacawake.com.
