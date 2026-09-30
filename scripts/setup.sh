#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
UV_BIN="${UV_BIN:-uv}"

command -v "$UV_BIN" >/dev/null || {
  echo "uv was not found. Install uv or set UV_BIN to its full path." >&2
  exit 1
}

"$UV_BIN" sync --locked
