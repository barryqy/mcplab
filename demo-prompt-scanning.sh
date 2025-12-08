#!/bin/bash

# Demo: Prompt Injection Scanning
# This demo shows how MCP Scanner detects prompt injection attacks

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║     MCP Scanner Demo - Prompt Injection Detection        ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Function to load cached Mistral key
load_mistral_key() {
    if [ -f .mcpscanner/.cache ]; then
        ENCRYPTED=$(grep session_token .mcpscanner/.cache | sed 's/^session_token=//' | tr -d ' \n\r\t')
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
except:
    sys.exit(1)
EOF
)
        if [ $? -eq 0 ] && [ -n "$MISTRAL_KEY" ]; then
            export MCP_SCANNER_LLM_API_KEY="$MISTRAL_KEY"
            export MCP_SCANNER_LLM_MODEL="mistral-large-latest"
            unset ENCRYPTED KEY
            return 0
        fi
        unset ENCRYPTED KEY
    fi
    return 1
}

# Try to load cached Mistral key
load_mistral_key 2>/dev/null || true

# Load environment (optional - for additional config)
if [ -f ".env" ]; then
    export $(cat .env | grep -v '^#' | xargs) 2>/dev/null || true
fi

# Check if MCP Scanner is installed
if ! command -v mcp-scanner &> /dev/null; then
    echo -e "${RED}Error: mcp-scanner not found${NC}"
    echo "Install with: pip install cisco-ai-mcp-scanner"
    exit 1
fi

echo -e "${YELLOW}📋 This demo will:${NC}"
echo "  1. Start an MCP server with malicious prompts"
echo "  2. Scan all prompts using available analyzers"
echo "  3. Display detected prompt injection attempts"
echo ""

read -p "Press Enter to continue..."

# Start the prompt injection server as HTTP
echo ""
echo -e "${CYAN}🚀 Starting prompt injection server as HTTP...${NC}"

# Start HTTP server in background
python3 launch_mcp_http.py examples/prompt-injection-server.py > /tmp/prompt-server.log 2>&1 &
HTTPSERVER_PID=$!
echo $HTTPSERVER_PID > /tmp/prompt-server.pid

# Give server time to start
sleep 3

# Verify server is running
if ps -p $HTTPSERVER_PID > /dev/null 2>&1; then
    echo -e "${GREEN}✓ HTTP Server started (PID: $HTTPSERVER_PID)${NC}"
else
    echo -e "${RED}✗ Server failed to start. Check log:${NC}"
    cat /tmp/prompt-server.log
    exit 1
fi

# Update trap to ensure HTTP server is killed on exit
trap "kill $HTTPSERVER_PID 2>/dev/null; rm -f /tmp/prompt-server.pid /tmp/prompt-server.log" EXIT

echo -e "${GREEN}✓ Server ready at http://127.0.0.1:8000/sse${NC}"

# Scan prompts
echo ""
echo -e "${CYAN}🔍 Scanning prompts for injection attacks...${NC}"
echo ""

# Check if LLM API key is configured
if [ -n "$MCP_SCANNER_LLM_API_KEY" ] || [ -n "$AWS_ACCESS_KEY_ID" ]; then
    echo -e "${GREEN}✓ LLM analyzer available - using LLM for prompt analysis${NC}"
    echo ""
    mcp-scanner --analyzers llm --format detailed \
        prompts --server-url http://127.0.0.1:8000/sse || true
else
    echo -e "${YELLOW}⚠ LLM analyzer not configured${NC}"
    echo -e "${CYAN}ℹ Using YARA analyzer for prompt scanning instead${NC}"
    echo ""
    mcp-scanner --analyzers yara --format detailed \
        prompts --server-url http://127.0.0.1:8000/sse || true
    echo ""
    echo -e "${CYAN}💡 Tip: To enable LLM-based prompt injection detection:${NC}"
    echo "   Run: ./0-init-lab.sh (to get lab credentials)"
    echo "   Or set your own key: export MCP_SCANNER_LLM_API_KEY='your-api-key'"
fi

echo ""
echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Demo complete!${NC}"
echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${CYAN}💡 Key Takeaways:${NC}"
echo "  • MCP servers can expose prompts that may contain injection attempts"
echo "  • YARA rules can detect suspicious patterns in prompts"
echo "  • LLM analyzers provide deeper semantic analysis (when configured)"
echo "  • Both analyzers help identify coercive instructions and exfiltration attempts"
echo ""

# Cleanup
kill $HTTPSERVER_PID 2>/dev/null || true
rm -f /tmp/prompt-server.pid /tmp/prompt-server.log

