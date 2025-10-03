#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

# Source all modules
source "${SCRIPT_DIR}/common.sh"
source "${SCRIPT_DIR}/certificates.sh"
source "${SCRIPT_DIR}/oidc.sh"

# Inputs via env
NOMAD_ADDR=${NOMAD_ADDR:-}
NOMAD_TOKEN=${NOMAD_TOKEN:-}
REGION=${REGION:-}
NAMESPACE=${NAMESPACE:-}
TLS_SKIP_VERIFY=${TLS_SKIP_VERIFY:-false}
CA_PEM=${CA_PEM:-}
CLIENT_CERT=${CLIENT_CERT:-}
CLIENT_KEY=${CLIENT_KEY:-}
OIDC_AUDIENCE=${OIDC_AUDIENCE:-nomad.example.com}
OIDC_AUTH_METHOD_NAME=${OIDC_AUTH_METHOD_NAME:-github}
DEBUG=${DEBUG:-false}

# Validate required inputs
require "nomad_addr" "$NOMAD_ADDR"

# Check for required tools
if ! command -v curl >/dev/null; then err "curl not found"; exit 2; fi
if ! command -v jq >/dev/null; then err "jq not found"; exit 2; fi
if ! command -v openssl >/dev/null; then err "jq not found"; exit 2; fi
if ! command -v base64 >/dev/null; then err "jq not found"; exit 2; fi

# Setup certificates and process meta data
setup_certificates

# Get Nomad Token via OIDC
get_oidc_token

exit 0
