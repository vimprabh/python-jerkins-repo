#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
UV_BIN="${UV_BIN:-uv}"

mkdir -p reports
"$UV_BIN" run --locked pytest -q --junitxml=reports/pytest.xml
