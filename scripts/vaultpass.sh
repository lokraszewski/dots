#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${BW_SESSION:-}" ]]; then
	echo "Bitwarden session not found. Run: bw login && bw unlock"
	exit 1
fi

bw get password ansible-vault-dots
