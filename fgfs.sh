#!/usr/bin/env bash

set -euo pipefail
(cd "$FG_ROOT" && git checkout release/2024.1 && git pull)
open /Applications/FlightGear.app
