#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."

scenario="${1:-}"
if [[ "$#" -ne 1 ]]; then
  echo "Usage: Scripts/seed.sh <normal|low-balance|private-reason>" >&2
  exit 2
fi
case "$scenario" in
  normal)
    if [[ ! -f Config/Backend.json || ! -f Config/TestAccounts.json ]]; then
      echo "Backend is not configured. Run Scripts/configure-backend.py with an authorized Supabase CLI login." >&2
      exit 2
    fi
    exec python3 Scripts/configure-backend.py --seed-normal
    ;;
  low-balance)
    if [[ ! -f Config/Backend.json || ! -f Config/TestAccounts.json ]]; then
      echo "Backend is not configured. Run Scripts/configure-backend.py with an authorized Supabase CLI login." >&2
      exit 2
    fi
    exec python3 Scripts/configure-backend.py --seed-low
    ;;
  private-reason)
    echo "Seed unavailable: private-reason requires the M4 private extension schema; no data changed." >&2
    exit 2
    ;;
  *)
    echo "Unknown scenario: $scenario. Choose normal, low-balance, or private-reason." >&2
    exit 2
    ;;
esac
