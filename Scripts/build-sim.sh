#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
project_root="$PWD"
mkdir -p builds
xcodebuild -scheme Weave -sdk iphonesimulator -configuration Debug -derivedDataPath build
app_path="build/Build/Products/Debug-iphonesimulator/Weave.app"
if [[ ! -d "$app_path" ]]; then
  echo "Build did not produce $app_path" >&2
  exit 1
fi
rm -f builds/Weave.zip
(cd "$(dirname "$app_path")" && /usr/bin/zip -qr "$project_root/builds/Weave.zip" Weave.app)
echo "Simulator app: builds/Weave.zip"
