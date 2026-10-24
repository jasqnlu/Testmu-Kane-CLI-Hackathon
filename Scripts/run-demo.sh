#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

device_name="${WEAVE_SIMULATOR_DEVICE:-iPhone 17 Pro}"
app_path="$PWD/build/Build/Products/Debug-iphonesimulator/Weave.app"

Scripts/build-sim.sh

if [[ -n "${WEAVE_SIMULATOR_UDID:-}" ]]; then
  device_udid="$WEAVE_SIMULATOR_UDID"
  device_state="$(xcrun simctl list devices available -j | python3 -c 'import json,sys; data=json.load(sys.stdin); matches=[d for group in data["devices"].values() for d in group if d["udid"]==sys.argv[1] and d.get("isAvailable",True)]; print(matches[0]["state"] if matches else "missing")' "$device_udid")"
  if [[ "$device_state" == "missing" ]]; then
    echo "Simulator UDID is unavailable: $device_udid" >&2
    exit 2
  fi
else
  simulator_list="$(xcrun simctl list devices available -j)"
  simulator_info="$(printf '%s' "$simulator_list" | python3 -c 'import json,sys; data=json.load(sys.stdin); found=[]
for runtime, devices in data["devices"].items():
 for d in devices:
  if d.get("name")==sys.argv[1] and d.get("isAvailable",True): found.append((runtime,d))
if not found: sys.exit("No available simulator named: "+sys.argv[1])
found.sort(key=lambda x:(x[1].get("state")!="Booted", x[0]), reverse=False)
print(found[0][1]["udid"], found[0][1]["state"])' "$device_name")" || exit 2
  read -r device_udid device_state <<< "$simulator_info"
fi

if [[ "$device_state" != "Booted" && "$device_state" != "Booting" ]]; then
  xcrun simctl boot "$device_udid"
fi
xcrun simctl bootstatus "$device_udid" -b
xcrun simctl install "$device_udid" "$app_path"
xcrun simctl launch "$device_udid" com.jasonlu.weave

echo "Weave is running on $device_name ($device_udid). No Apple signing or keys were used."
echo "Demo: request an exception, keep the reason private by default, and share an edited card only by choice."
