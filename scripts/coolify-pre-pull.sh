#!/usr/bin/env bash
# Pre-pull the custom Frappe image on the Coolify *host* before a deploy,
# so download/extract happens while old containers still serve traffic.
#
# Do NOT put this in Coolify "Pre Deployment Command".
# That hook docker-execs into an app container. Compose stacks have many
# containers (Coolify then fails with "Multiple containers found...") and
# app containers usually cannot run `docker pull` on the host.
#
# Preferred: .github/workflows/deploy-coolify.yml (SSH pre-pull → webhook).
# Manual:
#   COOLIFY_COMPOSE_DIR=/data/coolify/services/<uuid> \
#     bash scripts/coolify-pre-pull.sh
# then trigger Coolify deploy (webhook with ?force=true).
set -euo pipefail

IMAGE="${CUSTOM_IMAGE:-ghcr.io/sip-travel/frappe-custom:version-16}"

echo "Pre-pulling ${IMAGE} (keeps site up during download/extract)..."
docker pull "${IMAGE}"

docker image inspect "${IMAGE}" --format 'Image ID: {{.Id}}'
docker image inspect "${IMAGE}" --format 'Digest: {{index .RepoDigests 0}}'

if [ -n "${COOLIFY_COMPOSE_DIR:-}" ] && [ -d "${COOLIFY_COMPOSE_DIR}" ]; then
  COMPOSE_FILE="${COOLIFY_COMPOSE_DIR}/docker-compose.yml"
  if [ ! -f "${COMPOSE_FILE}" ]; then
    COMPOSE_FILE="$(find "${COOLIFY_COMPOSE_DIR}" -maxdepth 2 -name 'docker-compose*.yml' | head -1)"
  fi
  if [ -n "${COMPOSE_FILE}" ] && [ -f "${COMPOSE_FILE}" ]; then
    echo "Running compose pull in ${COOLIFY_COMPOSE_DIR}..."
    docker compose -f "${COMPOSE_FILE}" --project-directory "${COOLIFY_COMPOSE_DIR}" pull
  fi
fi

echo "Pre-pull complete. Trigger Coolify deploy with ?force=true on the webhook."
