#!/bin/bash

# Demo: API Scanning
# This demo shows how to use MCP Scanner's REST API

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║     MCP Scanner Demo - REST API Usage                     ║"
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

echo -e "${YELLOW}📋 This demo will:${NC}"
echo "  1. Start MCP Scanner API server on port 8080"
echo "  2. Demonstrate various API endpoints"
echo "  3. Show JSON request/response examples"
echo ""

read -p "Press Enter to continue..."

# Start API server
echo ""
echo -e "${CYAN}🚀 Starting MCP Scanner API server...${NC}"

# Check if port 8080 is available
if lsof -Pi :8080 -sTCP:LISTEN -t >/dev/null 2>&1 ; then
    echo -e "${YELLOW}Warning: Port 8080 is already in use${NC}"
    echo "Trying to stop existing process..."
    kill $(lsof -t -i:8080) 2>/dev/null || true
    sleep 2
fi

# Start API server in background
mcp-scanner-api --host 0.0.0.0 --port 8080 &
API_PID=$!

# Trap to ensure server is killed on exit
trap "kill $API_PID 2>/dev/null" EXIT

# Wait for server to start
echo "Waiting for API server to start..."
for i in {1..10}; do
    if curl -s http://localhost:8080/health > /dev/null 2>&1; then
        echo -e "${GREEN}✓ API server ready${NC}"
        break
    fi
    sleep 1
done

# Test health endpoint
echo ""
echo -e "${CYAN}1. Testing health endpoint...${NC}"
echo -e "${YELLOW}Request: GET /health${NC}"
curl -s http://localhost:8080/health | python3 -m json.tool
echo ""

# Scan a tool (example)
echo ""
echo -e "${CYAN}2. Scanning a tool via API...${NC}"
echo -e "${YELLOW}Request: POST /scan-tool${NC}"

cat << EOF | tee /tmp/scan-request.json
{
  "server_url": "https://mcp.deepwki.com/mcp",
  "tool_name": "search_web",
  "analyzers": ["yara"]
}
EOF

echo ""
curl -s -X POST http://localhost:8080/scan-tool \
    -H "Content-Type: application/json" \
    -d @/tmp/scan-request.json | python3 -m json.tool

# Show API documentation link
echo ""
echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Demo complete!${NC}"
echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${CYAN}💡 API Documentation:${NC}"
echo "  • Interactive docs: http://localhost:8080/docs"
echo "  • OpenAPI spec: http://localhost:8080/openapi.json"
echo ""
echo -e "${CYAN}💡 Available Endpoints:${NC}"
echo "  • POST /scan-tool - Scan a specific tool"
echo "  • POST /scan-all-tools - Scan all tools on a server"
echo "  • POST /scan-prompt - Scan a specific prompt"
echo "  • POST /scan-all-prompts - Scan all prompts"
echo "  • GET /health - Health check"
echo ""
echo -e "${YELLOW}Press Ctrl+C to stop the API server${NC}"

# Wait for user to stop
wait $API_PID

