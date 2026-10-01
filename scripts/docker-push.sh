#!/usr/bin/env bash
# Jenkins supplies credentials; local use can reuse a previous docker login.
set +x
set -euo pipefail

DOCKER_BIN="${DOCKER_BIN:-docker}"
: "${DOCKER_IMAGE:?Set DOCKER_IMAGE to your Docker Hub namespace/repository}"
: "${IMAGE_TAG:?Set IMAGE_TAG to the tag built locally}"
if [[ ! "$DOCKER_IMAGE" =~ ^[a-z0-9][a-z0-9_-]*/[a-z0-9][a-z0-9._-]*$ ]]; then
  echo "DOCKER_IMAGE must be a lowercase Docker Hub namespace/repository." >&2
  exit 1
fi

if [[ -n "${DOCKERHUB_USERNAME:-}" || -n "${DOCKERHUB_TOKEN:-}" ]]; then
  : "${DOCKERHUB_USERNAME:?Set both Docker Hub credential variables}"
  : "${DOCKERHUB_TOKEN:?Set both Docker Hub credential variables}"
  # Keep the agent's engine endpoint when isolating its registry credentials.
  # Docker Desktop's active context is stored in the original Docker config.
  if [[ -n "${DOCKER_CONTEXT:-}" || -z "${DOCKER_HOST:-}" ]]; then
    docker_endpoint=$("$DOCKER_BIN" context inspect --format '{{.Endpoints.docker.Host}}')
    export DOCKER_HOST="$docker_endpoint"
  fi
  unset DOCKER_CONTEXT
  docker_auth_dir=$(mktemp -d "${TMPDIR:-/tmp}/jenkins-docker-auth.XXXXXX")
  trap 'rm -rf "$docker_auth_dir"' EXIT
  export DOCKER_CONFIG="$docker_auth_dir"
  printf '%s' "$DOCKERHUB_TOKEN" | "$DOCKER_BIN" login \
    --username "$DOCKERHUB_USERNAME" --password-stdin
fi

"$DOCKER_BIN" push "docker.io/${DOCKER_IMAGE}:${IMAGE_TAG}"
