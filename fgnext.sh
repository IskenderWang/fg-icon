#!/usr/bin/env bash
#
# Automates running the latest FlightGear nightly on macOS
set -euo pipefail

INSTALL_DIR="$HOME/flightgear"
CURRENT_VER="$INSTALL_DIR/fg_nightly.txt"
NIGHTLY_URL="https://www.flightgear.org/download/nightly/"

cleanup() {
  # Detach before removing TEMP, since the DMG is mounted inside it
  echo "Cleaning up..."
  if [[ -d ${MOUNT_POINT:-} ]]; then
    if ! hdiutil detach "$MOUNT_POINT" -quiet &&
      ! hdiutil detach "$MOUNT_POINT" -force -quiet; then
      # Removing TEMP now would pull the .dmg out from under a live mount
      echo "Warning: could not unmount $MOUNT_POINT; leaving $TEMP behind." >&2
      return 0
    fi
  fi
  # We knew that TEMP was set if MOUNT_POINT was, but now we also check TEMP
  [[ -d ${TEMP:-} ]] && rm -r "$TEMP"
  return 0
}

launch() {
  # Assumes $FG_ROOT is set, handles error otherwise
  if [[ -d ${FG_ROOT:-} ]]; then
    echo "Pulling FGData..."
    # A dirty tree or no network shouldn't stop us flying on slightly stale data
    if ! (cd "$FG_ROOT" && git checkout next && git pull); then
      echo "Warning: could not update FGData; launching with the current tree." >&2
    fi
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

echo "Checking for latest nightly..." # Since only one .dmg URL grep works fine
# head -n1 in case a second link appears, || true so a no-match reaches the
# check below instead of tripping set -e with no message
DMG_URL=$(curl -fsSL "$NIGHTLY_URL" | grep -o 'https://gitlab\.com[^"]*\.dmg' |
  head -n1) || true

if [[ -z $DMG_URL ]]; then
  echo "Error: Could not find .dmg URL on nightly page." >&2
  exit 1
fi

mkdir -p "$INSTALL_DIR" # Not depending on assumption it exists already
DMG_NAME=$(basename "$DMG_URL")

# Also check the app itself, in case it was moved or trashed by hand
if [[ -f $CURRENT_VER ]] && [[ "$(cat "$CURRENT_VER")" == "$DMG_NAME" ]] &&
  [[ -d "$INSTALL_DIR/FlightGear.app" ]]; then
  echo "Already up to date: $DMG_NAME"
  launch
  exit
fi

TEMP=$(mktemp -d)
MOUNT_POINT="$TEMP/mnt" # Create private mountpoint
trap cleanup EXIT

echo "Downloading $DMG_NAME..."
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
launch
