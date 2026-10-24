#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."

scenario="${1:-}"
if [[ "$#" -ne 1 ]]; then
  echo "Usage: Scripts/seed.sh <normal|low-balance|private-reason>" >&2
  exit 2
fi
case "$scenario" in
  normal|low-balance|private-reason) ;;
  *)
    echo "Unknown scenario: $scenario. Choose normal, low-balance, or private-reason." >&2
    exit 2
    ;;
esac

# M0 intentionally has no seed implementation. Never treat this as a successful reset.
echo "Seed unavailable: Supabase backend and test-user seed RPC are not configured for '$scenario'." >&2
echo "No server data was changed. Complete M1 backend setup before running feature verification." >&2
exit 2
