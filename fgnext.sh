#!/usr/bin/env bash
#
# Automates running the latest FlightGear nightly on macOS
set -euo pipefail

INSTALL_DIR="$HOME/flightgear"
CURRENT_VER="$INSTALL_DIR/fg_nightly.txt"
NIGHTLY_URL="https://www.flightgear.org/download/nightly/"

cleanup() {
  # Detach before removing TEMP, since the DMG is mounted inside it
  [[ -d ${MOUNT_POINT:-} ]] &&
    { hdiutil detach "$MOUNT_POINT" -quiet || hdiutil detach "$MOUNT_POINT" -force -quiet; }
  [[ -n ${TEMP:-} ]] && rm -r "$TEMP"
}

launch() {
  if [[ -d ${FG_ROOT:-} ]]; then
    echo "Pulling FGData..."
    (cd "$FG_ROOT" && git checkout next && git pull)
    echo "Launching..."
    open "$INSTALL_DIR/FlightGear.app"
    return 0
  else
    # shellcheck disable=SC2016
    [[ -z ${FG_ROOT:-} ]] && echo 'Error: $FG_ROOT is not set.' >&2 ||
      echo "Error: Could not find FGData at $FG_ROOT." >&2
    return 1
  fi
}

mkdir -p "$INSTALL_DIR"

echo "Checking for latest nightly..." # Since only one .dmg URL this works fine
DMG_URL=$(curl -s "$NIGHTLY_URL" | grep -o 'https://gitlab\.com[^"]*\.dmg')

if [[ -z $DMG_URL ]]; then
  echo "Error: Could not find .dmg URL on nightly page." >&2
  exit 1
fi

DMG_NAME=$(basename "$DMG_URL")

if [[ -f $CURRENT_VER ]] && [[ "$(cat "$CURRENT_VER")" == "$DMG_NAME" ]]; then
  echo "Already up to date: $DMG_NAME"
  launch && exit 0 || exit 1
fi

echo "Downloading $DMG_NAME..."
TEMP=$(mktemp -d)
MOUNT_POINT="$TEMP/mnt" # Private mountpoint, so a stray /Volumes/FlightGear can't clash
trap cleanup EXIT
curl -fL --progress-bar -o "$TEMP/$DMG_NAME" "$DMG_URL"

echo "Mounting DMG..."
hdiutil attach "$TEMP/$DMG_NAME" -mountpoint "$MOUNT_POINT" -nobrowse -quiet

if [[ ! -d "$MOUNT_POINT/FlightGear.app" ]]; then
  echo "Error: FlightGear.app not found on mounted DMG." >&2
  exit 1
fi

# As this is mac we can use trash and ditto, typically we would use rm and cp (with the proper options) for this
[[ -d "$INSTALL_DIR/FlightGear.app" ]] && trash "$INSTALL_DIR/FlightGear.app"

echo "Installing FlightGear..."
ditto "$MOUNT_POINT/FlightGear.app" "$INSTALL_DIR/FlightGear.app"

# Update the current version file now that installation is complete
echo "$DMG_NAME" >"$CURRENT_VER"

echo "Installed: $DMG_NAME"
launch && echo "Cleaning up..."
