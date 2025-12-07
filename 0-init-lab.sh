#!/bin/bash

# MCP Scanner Lab - Environment Setup Script
# This script sets up the lab environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Print header
echo -e "${CYAN}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║     MCP Scanner Lab - Environment Setup                   ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo ""
echo -e "${GREEN}Welcome to the MCP Scanner Lab!${NC}"
echo ""
echo -e "${CYAN}MCP Scanner has 3 analyzer engines:${NC}"
echo -e "  1. ${GREEN}YARA Analyzer${NC} - Pattern matching (NO API KEY REQUIRED) ✓"
echo -e "  2. ${YELLOW}LLM Analyzer${NC} - AI-powered analysis (optional - requires your own LLM API key)"
echo -e "  3. ${YELLOW}API Analyzer${NC} - Cisco AI Defense (optional - enterprise subscription)"
echo ""
echo -e "${CYAN}For this lab:${NC}"
echo -e "  • YARA analyzer works immediately without any setup"
echo -e "  • You can optionally add your own API keys to .env file for advanced features"
echo ""

# Create .env file with template
echo -e "${CYAN}📝 Creating .env configuration file...${NC}"

cat > .env << 'EOF'
# MCP Scanner Lab Configuration
# 
# YARA analyzer
# To use it: mcp-scanner --analyzers yara <options>
#
# Optional: Add your own API keys below for advanced features

# Optional: Cisco AI Defense API (enterprise feature)
# Uncomment and add your key to use the API analyzer
# MCP_SCANNER_API_KEY=your_api_key_here
# MCP_SCANNER_ENDPOINT=https://us.api.inspect.aidefense.security.cisco.com/api/v1

# Optional: LLM Provider (for LLM analyzer)
# Uncomment and add your key to use the LLM analyzer
# Examples:
#   OpenAI: MCP_SCANNER_LLM_API_KEY=sk-...
#   AWS Bedrock: Set AWS credentials via AWS_PROFILE or AWS_* env vars
#
# MCP_SCANNER_LLM_API_KEY=your_llm_api_key_here
# MCP_SCANNER_LLM_MODEL=gpt-4o
# MCP_SCANNER_LLM_BASE_URL=https://api.openai.com/v1
EOF

echo -e "${GREEN}✓ Configuration file created${NC}"

# Print success message
echo ""
echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Lab setup complete!${NC}"
echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${CYAN}💡 You can now use MCP Scanner with YARA:${NC}"
echo ""
echo -e "   • ${YELLOW}python3 mcp_lab.py${NC}              (Interactive lab tool)"
echo -e "   • ${YELLOW}./demo-complete-audit.sh${NC}        (Complete security audit)"
echo -e "   • ${YELLOW}./demo-prompt-scanning.sh${NC}       (Prompt injection demo)"
echo ""
echo -e "${CYAN}💡 To add optional credentials for advanced features:${NC}"
echo -e "   • Edit the ${YELLOW}.env${NC} file and uncomment the API keys you want to use"
echo -e "   • Then run: ${YELLOW}source .env${NC}"
echo ""
echo -e "${CYAN}💡 Example commands (YARA - no setup needed):${NC}"
echo -e "   ${YELLOW}mcp-scanner --analyzers yara --scan-known-configs${NC}"
echo -e "   ${YELLOW}mcp-scanner --analyzers yara --stdio-command python3 --stdio-arg=examples/safe-mcp-server.py${NC}"
echo ""
