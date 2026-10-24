#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."

selection="${1:-smoke}"
if [[ "$#" -gt 1 ]]; then
  echo "Usage: Scripts/verify.sh <tag|Tests/Kane/path_test.md>" >&2
  exit 2
fi
if ! command -v kane-cli >/dev/null 2>&1; then
  echo "Kane CLI is missing. Install the hackathon release candidate and sign in first; see README.md." >&2
  exit 2
fi

Scripts/build-sim.sh

if [[ -z "$(find Tests/Kane -type f -name '*_test.md' -print -quit)" ]]; then
  echo "No committed Kane tests exist under Tests/Kane yet. No verification ran." >&2
  echo "Run the kane-assure workflow from Requirements/acceptance-criteria.md, then retry." >&2
  exit 2
fi

if [[ "$selection" == "smoke" ]]; then
  echo "M0 BLANK-APP ONLY: smoke skips server seeding; it cannot verify auth, credits, privacy, or AI." >&2
  echo "Kane terminal result and process exit determine this run's outcome." >&2
else
  Scripts/seed.sh "${WEAVE_SCENARIO:-normal}"
fi

case "$selection" in
  *_test.md)
    if [[ "$selection" != Tests/Kane/* || ! -f "$selection" ]]; then
      echo "Test path must name an existing Tests/Kane/*_test.md file relative to the repository root." >&2
      exit 2
    fi
    exec Scripts/with-kane-simulator.sh env KANE_CLI_USER_AGENT=codex kane-cli testrun run "$selection" --parallel 1 --agent < /dev/null
    ;;
  *)
    if [[ "$selection" == "smoke" ]]; then
      exec Scripts/with-kane-simulator.sh env KANE_CLI_USER_AGENT=codex kane-cli testrun run --match '^Tests/Kane/setup/' --tags smoke --parallel 1 --agent < /dev/null
    fi
    exec Scripts/with-kane-simulator.sh env KANE_CLI_USER_AGENT=codex kane-cli testrun run --match '^Tests/Kane/' --tags "$selection" --parallel 1 --agent < /dev/null
    ;;
esac
