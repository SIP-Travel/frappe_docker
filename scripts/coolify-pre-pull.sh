#!/usr/bin/env bash
# Run this as Coolify "Pre Deployment Command" so the ~800MB custom image
# is downloaded/extracted while the current containers are still serving traffic.
# Coolify Advanced → Pre Deployment Command:
#   bash scripts/coolify-pre-pull.sh
set -euo pipefail

IMAGE="${CUSTOM_IMAGE:-ghcr.io/sip-travel/frappe-custom:version-16}"

echo "Pre-pulling ${IMAGE} (keeps site up during download/extract)..."
docker pull "${IMAGE}"
echo "Pre-pull complete."
