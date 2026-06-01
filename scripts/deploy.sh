#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="${SCRIPT_DIR}/../infrastructure/environments/dev"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() { echo -e "${YELLOW}$1${NC}"; }
success() { echo -e "${GREEN}$1${NC}"; }
error() { echo -e "${RED}$1${NC}" >&2; }

# Pre-flight checks
check_aws_credentials() {
    if ! aws sts get-caller-identity &> /dev/null; then
        error "AWS credentials not configured"
        exit 1
    fi
}

check_terraform() {
    if ! command -v terraform &> /dev/null; then
        error "Terraform not installed"
        exit 1
    fi
}

# Main
log "Checking prerequisites..."
check_terraform
check_aws_credentials

log "Changing to infrastructure directory..."
cd "${INFRA_DIR}"

log "Running terraform init..."
terraform init

log "Running terraform plan..."
terraform plan

log "Running terraform apply..."
terraform apply -auto-approve

success "Deployment complete!"
