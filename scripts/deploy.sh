#!/usr/bin/env bash
# Safe Jenkins entry point. This checked-in file is deliberately not run with sudo.
# The sudoers rule permits only this fixed, root-owned helper with no arguments.
set -euo pipefail
HELPER="/usr/local/sbin/deploy-college-site"
if [[ ! -x "$HELPER" ]]; then
  echo "ERROR: $HELPER is not installed. Follow docs/IMPLEMENTATION_GUIDE.md first." >&2
  exit 1
fi
exec sudo -n "$HELPER"
