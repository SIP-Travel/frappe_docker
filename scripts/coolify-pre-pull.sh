#!/usr/bin/env bash
# Pre-pull the custom Frappe image on the Coolify *host* before a deploy,
# so download/extract happens while old containers still serve traffic.
#
# Do NOT put this in Coolify "Pre Deployment Command".
# That hook docker-execs into an app container. Compose stacks have many
# containers (Coolify then fails with "Multiple containers found...") and
# app containers usually cannot run `docker pull` on the host.
#
# Run on the deployment server instead, e.g.:
#   ssh user@server 'bash /path/to/frappe_docker/scripts/coolify-pre-pull.sh'
# or from CI right before triggering the Coolify deploy webhook.
set -euo pipefail

IMAGE="${CUSTOM_IMAGE:-ghcr.io/sip-travel/frappe-custom:version-16}"

echo "Pre-pulling ${IMAGE} (keeps site up during download/extract)..."
docker pull "${IMAGE}"
echo "Pre-pull complete."
