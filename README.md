# fg-icon

FlightGear icon for macOS which improves on the original we had introduced (big up Michael Danilov for that) by better aligning with the app icon style guidelines. Of course, I used no design kits provided by Apple (as that would probably lead to licensing trouble) other than to get a sense of how it should look. Created entirely with the help of Inkscape, my terminal, and the guidelines, as listed below.

## Scripts

This repo has since picked up two launcher scripts for macOS. Both expect `$FG_ROOT` to point at an FGData checkout, and both put FGData on the branch matching the build before opening the app. Neither gives up if the pull fails: a dirty tree or no network just means you fly on slightly stale data.

- `fgfs.sh` — runs the stable release from `/Applications`, with FGData on `release/2024.1`. Bump the `BRANCH` variable when you move to a newer release.
- `fgnext.sh` — fetches the latest nightly `.dmg` from the [nightly page](https://www.flightgear.org/download/nightly/), installs it into `~/flightgear` if it differs from the one already there, and runs it with FGData on `next`.

`mkicns.sh` is the icon build itself: it resizes `FlightGear_app_icon.png` into every size the iconset needs and packs the result into `FlightGear.icns`.

## Sources

- [@jaredsinclair's comment](https://forums.developer.apple.com/forums/thread/670578)
- [Apple Developer guidelines for app icons](https://developer.apple.com/design/human-interface-guidelines/app-icons)
- [FlightGear logo itself](https://en.wikipedia.org/wiki/File:FlightGear_Logo.svg)
- [Commands used to create the full iconset](https://stackoverflow.com/questions/12306223/how-to-manually-create-icns-files-using-iconutil)
