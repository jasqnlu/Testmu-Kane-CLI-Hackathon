#!/bin/bash
# Configure Kane's Appium transport; Kane remains the only UI verifier.
set -euo pipefail

if [[ "$#" -eq 0 ]]; then
  echo "Usage: Scripts/with-kane-simulator.sh <command> [arguments...]" >&2
  exit 2
fi

# A caller-supplied server is deliberate: do not start, modify, or stop it.
if [[ -n "${KANE_APPIUM_URL:-}" ]]; then
  exec "$@"
fi

port="${WEAVE_APPIUM_PORT:-4725}"
if [[ ! "$port" =~ ^[0-9]+$ || "${#port}" -gt 5 ]]; then
  echo "WEAVE_APPIUM_PORT must be an integer from 1 through 65535." >&2
  exit 2
fi
port=$((10#$port))
if (( port < 1 || port > 65535 )); then
  echo "WEAVE_APPIUM_PORT must be an integer from 1 through 65535." >&2
  exit 2
fi

for tool in node curl lsof; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "Required simulator helper tool is missing: $tool" >&2
    exit 2
  fi
done

url="http://127.0.0.1:$port"
if lsof -nP -iTCP:"$port" -sTCP:LISTEN >/dev/null 2>&1 || \
   curl --silent --fail --max-time 1 "$url/status" >/dev/null 2>&1; then
  echo "Port $port is already occupied. Its server was not changed or stopped." >&2
  echo "Set KANE_APPIUM_URL=$url deliberately to use it, or choose a free WEAVE_APPIUM_PORT." >&2
  exit 2
fi

# Prefer the bundle verified for this project; tolerate later installed bundles.
deps_root="$HOME/.testmuai/kaneai/mobile/deps"
simulator_bundle=""
shopt -s nullglob
for candidate in "$deps_root/0.0.1/simulator" "$deps_root"/*/simulator; do
  if [[ -f "$candidate/appium/node_modules/appium/build/lib/main.js" && \
        -d "$candidate/appium-home/node_modules/appium-xcuitest-driver" ]]; then
    simulator_bundle="$candidate"
    break
  fi
done
shopt -u nullglob
if [[ -z "$simulator_bundle" ]]; then
  echo "Kane's installed simulator Appium bundle was not found under $deps_root." >&2
  echo "Run kane-cli doctor --target simulator --install, then retry." >&2
  exit 2
fi

log_dir="$(mktemp -d "${TMPDIR:-/tmp}/weave-appium.XXXXXX")"
log_file="$log_dir/server.log"
server_pid=""
cleanup() {
  if [[ -n "$server_pid" ]]; then
    if kill -0 "$server_pid" 2>/dev/null; then
      kill "$server_pid" 2>/dev/null || true
    fi
    wait "$server_pid" 2>/dev/null || true
  fi
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

APPIUM_HOME="$simulator_bundle/appium-home" \
  node "$simulator_bundle/appium/node_modules/appium/build/lib/main.js" \
  --address 127.0.0.1 --port "$port" --base-path / \
  --default-capabilities '{"appium:isHeadless":true}' > "$log_file" 2>&1 &
server_pid=$!

ready=false
for ((attempt = 0; attempt < 60; attempt++)); do
  if ! kill -0 "$server_pid" 2>/dev/null; then
    echo "Headless Appium stopped before becoming ready. See $log_file" >&2
    exit 2
  fi
  if curl --silent --fail --max-time 1 "$url/status" | \
     node -e 'let s=""; process.stdin.on("data", d => s += d); process.stdin.on("end", () => { try { process.exit(JSON.parse(s).value?.ready === true ? 0 : 1); } catch { process.exit(1); } });' 2>/dev/null; then
    ready=true
    break
  fi
  sleep 0.5
done
if [[ "$ready" != true ]]; then
  echo "Headless Appium did not become ready within the bounded startup wait. See $log_file" >&2
  exit 2
fi

echo "Kane simulator transport: headless Appium at $url; server log $log_file" >&2
set +e
KANE_APPIUM_URL="$url" "$@"
command_exit=$?
set -e
exit "$command_exit"
