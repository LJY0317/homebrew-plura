# Homebrew tap for Plura Desktop

This tap installs the standalone macOS CLI/runtime for [Plura Desktop](https://github.com/LJY0317/plura-desktop) without requiring a separate Python environment or Apple Developer membership.

Plura Desktop is an unofficial community project and is not affiliated with, endorsed by, or supported by OpenAI.

The formula requires **macOS 14 (Sonoma) or newer**, matching the current minimum OS for the official ChatGPT macOS app.

## Install

The shortest form automatically adds this tap:

```sh
brew install LJY0317/plura/plura-desktop
```

Or tap it explicitly:

```sh
brew tap LJY0317/plura
brew install plura-desktop
```

Then create the first managed profile:

```sh
plura-desktop status --profile 2
plura-desktop install --profile 2
open "$HOME/Applications/ChatGPT Profile 2.app"
```

Sign in normally in the new Profile 2 window. Do not copy cookies, authentication files, profile databases, or conversations from another profile.

## Update

Quit managed ChatGPT Profile windows normally, then run:

```sh
brew update
brew upgrade plura-desktop
plura-desktop refresh --profile 2
```

The formula uses Homebrew's stable `opt` path for Plura-managed selectors/control helpers, so they do not embed a versioned Cellar path across upgrades.

## Remove

Plura Desktop manages profile state outside the Homebrew Cellar. Remove each managed profile before uninstalling the formula:

```sh
plura-desktop uninstall --profile 2
plura-desktop uninstall --profile 2 --yes
brew uninstall plura-desktop
```

The official ChatGPT app/default profile are never uninstall targets.

## Trust model

This tap downloads the architecture-specific standalone runtime from an immutable Plura Desktop GitHub Release and verifies its SHA-256 through Homebrew. Formula updates additionally verify upstream `SHA256SUMS`, `RELEASE-METADATA.json`, and GitHub artifact attestations before the candidate is tested on both Apple Silicon and Intel macOS runners.

This free Homebrew path is **not** Apple Developer ID signing/notarization. The normal suffix-free notarized DMG remains a separate future distribution path.

## Issues and source

Report Plura Desktop bugs and feature requests in the main [`LJY0317/plura-desktop`](https://github.com/LJY0317/plura-desktop) repository. This tap intentionally keeps its own Issues disabled so runtime and package-manager reports stay in one place.

## Maintainer update flow

A scheduled workflow automatically renders the newest immutable semantic-version upstream release, verifies its provenance, tests the upgrade on both Apple Silicon and Intel, and commits the formula only after both pass. A separate drift workflow runs later as an alarm if the tap still falls behind.

The manual verified fallback is:

```sh
scripts/update-formula.sh VERSION
brew style LJY0317/plura/plura-desktop
brew audit --strict LJY0317/plura/plura-desktop
brew test LJY0317/plura/plura-desktop
```
