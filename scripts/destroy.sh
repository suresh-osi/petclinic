#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="${SCRIPT_DIR}/../infrastructure/environments/dev"

RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "$1"; }
warn() { echo -e "${YELLOW}$1${NC}"; }

warn "WARNING: This will destroy all infrastructure in dev environment!"
read -p "Are you sure? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    log "Destroy cancelled"
    exit 0
fi

log "Running terraform destroy..."
terraform -C "${INFRA_DIR}" destroy -auto-approve

log "Destruction complete!"
