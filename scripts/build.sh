#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
UV_BIN="${UV_BIN:-uv}"

"$UV_BIN" build --out-dir dist
