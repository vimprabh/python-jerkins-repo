#!/usr/bin/env bash
set -euo pipefail

DOCKER_BIN="${DOCKER_BIN:-docker}"
DOCKER_IMAGE="${DOCKER_IMAGE:-jenkins-uv-starter}"
IMAGE_TAG="${IMAGE_TAG:-local}"

run_args=(--rm)
if [[ -n "${DOCKER_PLATFORM:-}" ]]; then
  run_args+=(--platform "$DOCKER_PLATFORM")
fi
output=$("$DOCKER_BIN" run "${run_args[@]}" "docker.io/${DOCKER_IMAGE}:${IMAGE_TAG}" --name Jenkins)
if [[ "$output" != "Hello, Jenkins!" ]]; then
  echo "Container check failed. Expected 'Hello, Jenkins!', got: $output" >&2
  exit 1
fi
echo "Container check passed: $output"
