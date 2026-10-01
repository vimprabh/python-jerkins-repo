#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
DOCKER_BIN="${DOCKER_BIN:-docker}"
DOCKER_IMAGE="${DOCKER_IMAGE:-jenkins-uv-starter}"
IMAGE_TAG="${IMAGE_TAG:-local}"

build_args=(--tag "docker.io/${DOCKER_IMAGE}:${IMAGE_TAG}")
if [[ -n "${DOCKER_PLATFORM:-}" ]]; then
  build_args+=(--platform "$DOCKER_PLATFORM")
fi
"$DOCKER_BIN" build "${build_args[@]}" .
