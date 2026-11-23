#!/bin/bash

set -euo pipefail

REPO="bmax121/KernelPatch"

TAG_URL=$(curl -fsSL -o /dev/null -w '%{url_effective}' \
  "https://github.com/$REPO/releases/latest")

TAG="${TAG_URL##*/}"

echo "Latest release: $TAG"

ASSETS=$(curl -fsSL \
  "https://github.com/$REPO/releases/expanded_assets/$TAG")

download_asset() {
  local NAME="$1"

  local URL
  URL=$(printf '%s' "$ASSETS" |
    grep -oE "href=\"[^\"]*/releases/download/[^\" ]+/${NAME}\"" |
    head -n 1 |
    sed -E 's/^href="([^"]+)"$/\1/')

  if [ -z "$URL" ]; then
    echo "Asset not found: $NAME" >&2
    exit 1
  fi

  URL="https://github.com${URL}"

  echo "Downloading $NAME..."

  curl -fL --retry 3 \
    -o "$NAME" \
    "$URL"
}

download_asset "kpimg-android"
download_asset "kptools-linux"

chmod +x kptools-linux

echo "Downloaded successfully:"
ls -lh kpimg-android kptools-linux


chmod +x ./kpimg-android
chmod +x ./kptools-linux

./kptools-linux -p --image $KERNEL_IMAGE --kpimg kpimg-android --out $OUTPUT_IMAGE
