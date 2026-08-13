#!/usr/bin/env bash
#
# Runs the stable FlightGear release on macOS against matching FGData
set -euo pipefail

APP="/Applications/FlightGear.app"
BRANCH="release/2024.1" # Bump alongside the installed release

if [[ ! -d ${FG_ROOT:-} ]]; then
  # shellcheck disable=SC2016
  [[ -z ${FG_ROOT:-} ]] && echo 'Error: $FG_ROOT is not set.' >&2 ||
    echo "Error: Could not find FGData at $FG_ROOT." >&2
  exit 1
fi

echo "Pulling FGData..."
if ! (cd "$FG_ROOT" && git checkout "$BRANCH" && git pull); then
  echo "Warning: could not update FGData; launching with the current tree." >&2
fi

echo "Launching..."
open "$APP"
