#!/usr/bin/env bash

set -euo pipefail

# Application version
APP_VERSION="$(curl -sSL --retry 5 --retry-delay 2 "https://readarr.servarr.com/v1/update/develop/changes" | jq -r '.[] | select ( .branch = "develop" ) | .version' | sort -rn | head -n 1)"

# Export C_VERSION
echo "export C_VERSION=\""$APP_VERSION"\"" >> $BASH_ENV
