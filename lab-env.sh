#!/bin/bash

# Load the lab's LLM settings into the names mcp-scanner uses.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -f "${SCRIPT_DIR}/.env" ]; then
    set -a
    # shellcheck disable=SC1091
    source "${SCRIPT_DIR}/.env"
    set +a
fi

if [ -z "${MCP_SCANNER_LLM_API_KEY:-}" ] && [ -n "${LLM_API_KEY:-}" ]; then
    export MCP_SCANNER_LLM_API_KEY="${LLM_API_KEY}"
fi

if [ -z "${MCP_SCANNER_LLM_BASE_URL:-}" ] && [ -n "${LLM_BASE_URL:-}" ]; then
    export MCP_SCANNER_LLM_BASE_URL="${LLM_BASE_URL}"
fi

if [ -n "${MCP_SCANNER_LLM_API_KEY:-}" ] && [ -n "${MCP_SCANNER_LLM_BASE_URL:-}" ] && [ -z "${MCP_SCANNER_LLM_MODEL:-}" ]; then
    export MCP_SCANNER_LLM_MODEL="gpt-4o"
fi
