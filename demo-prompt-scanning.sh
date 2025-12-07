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

# Load environment
if [ -f ".env" ]; then
    export $(cat .env | grep -v '^#' | xargs)
else
    echo -e "${RED}Error: .env file not found${NC}"
    echo "Run ./0-init-lab.sh first"
    exit 1
fi

# Check if MCP Scanner is installed
if ! command -v mcp-scanner &> /dev/null; then
    echo -e "${RED}Error: mcp-scanner not found${NC}"
    echo "Install with: pip install cisco-ai-mcp-scanner"
    exit 1
fi

echo -e "${YELLOW}📋 This demo will:${NC}"
echo "  1. Start an MCP server with malicious prompts"
echo "  2. Scan all prompts using LLM analyzer"
echo "  3. Display detected prompt injection attempts"
echo ""

read -p "Press Enter to continue..."

# Start the prompt injection server
echo ""
echo -e "${CYAN}🚀 Starting prompt injection server...${NC}"

# Run server in background
python3 examples/prompt-injection-server.py &
SERVER_PID=$!

# Give server time to start
sleep 2

# Trap to ensure server is killed on exit
trap "kill $SERVER_PID 2>/dev/null" EXIT

echo -e "${GREEN}✓ Server started (PID: $SERVER_PID)${NC}"

# Scan prompts
echo ""
echo -e "${CYAN}🔍 Scanning prompts for injection attacks...${NC}"
echo ""

# Use mcp-scanner to scan the stdio server's prompts
mcp-scanner --analyzers llm --format detailed \
    --stdio-command python3 --stdio-arg=examples/prompt-injection-server.py \
    prompts || true

echo ""
echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Demo complete!${NC}"
echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${CYAN}💡 Key Takeaways:${NC}"
echo "  • LLM analyzer detects prompt injection attempts"
echo "  • Semantic analysis finds coercive instructions"
echo "  • Hidden exfiltration attempts are identified"
echo ""

# Cleanup
kill $SERVER_PID 2>/dev/null || true

