#!/usr/bin/env bash
# Source this, do not run it: `. ./scripts/bwunlock.sh`
# Exports BW_SESSION unless the current one is already unlocked.

if ! command -v bw >/dev/null 2>&1; then
  echo "bw (bitwarden-cli) not found in PATH" >&2
  return 1 2>/dev/null || exit 1
fi

if [[ -n "${BW_SESSION:-}" ]] && bw unlock --check >/dev/null 2>&1; then
  return 0 2>/dev/null || exit 0
fi

# bw unlock invalidates any previous session key, so only reach here when the
# existing one is missing or stale.
if ! _bw_session=$(bw unlock --raw); then
  echo "bw unlock failed" >&2
  unset _bw_session
  return 1 2>/dev/null || exit 1
fi

export BW_SESSION="$_bw_session"
unset _bw_session
