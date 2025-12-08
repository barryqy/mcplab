#!/bin/bash
# Load cached MCP Scanner credentials for manual use
# Usage: source ./load-credentials.sh

if [ ! -f .mcpscanner/.cache ]; then
    echo "❌ No cached credentials found. Run ./0-init-lab.sh first."
    return 1 2>/dev/null || exit 1
fi

# Extract and trim whitespace
ENCRYPTED=$(grep session_token .mcpscanner/.cache | cut -d= -f2 | tr -d ' \n\r\t')
KEY="${DEVENV_USER:-default-key-fallback}"

# Export for Python subprocess
export ENCRYPTED KEY

# Decrypt using Python
MISTRAL_KEY=$(python3 << 'EOF'
import base64
import sys
import os

encrypted = os.environ.get('ENCRYPTED', '').strip()
key = os.environ.get('KEY', 'default-key-fallback').strip()

try:
    data = base64.b64decode(encrypted)
    key_repeated = (key * (len(data) // len(key) + 1))[:len(data)]
    result = bytes(a ^ b for a, b in zip(data, key_repeated.encode())).decode()
    print(result, end='')
except Exception as e:
    print(f"ERROR: {e}", file=sys.stderr)
    sys.exit(1)
EOF
)

if [ $? -eq 0 ] && [ -n "$MISTRAL_KEY" ]; then
    export MCP_SCANNER_LLM_API_KEY="$MISTRAL_KEY"
    export MCP_SCANNER_LLM_MODEL="mistral-large-latest"
    unset ENCRYPTED KEY
    
    echo "✅ Credentials loaded for current session"
    echo "   Model: mistral-large-latest"
    echo ""
    echo "💡 You can now run: mcp-scanner --analyzers llm ..."
    return 0 2>/dev/null || exit 0
else
    unset ENCRYPTED KEY
    echo "❌ Failed to decrypt credentials"
    return 1 2>/dev/null || exit 1
fi

