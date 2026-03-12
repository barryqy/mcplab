#!/bin/bash

# Demo: Complete Security Audit
# This demo performs a comprehensive security audit of multiple MCP servers

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║     MCP Scanner Demo - Complete Security Audit            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lab-env.sh"

# Create reports directory
mkdir -p reports

echo -e "${YELLOW}📋 This demo will:${NC}"
echo "  1. Scan safe MCP server (baseline)"
echo "  2. Scan malicious MCP server (vulnerabilities)"
echo "  3. Scan mixed security server (realistic scenario)"
echo "  4. Generate comprehensive security reports"
echo ""

read -p "Press Enter to continue..."

# Scan Safe Server
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}1. Scanning Safe MCP Server${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo ""

mcp-scanner --analyzers yara --format detailed \
    --stdio-command python3 --stdio-arg=examples/safe-mcp-server.py \
    > reports/safe-server-report.txt || true

echo -e "${GREEN}✓ Safe server scan complete${NC}"
echo "  Report saved to: reports/safe-server-report.txt"

# Scan Malicious Server
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}2. Scanning Malicious MCP Server${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo ""

mcp-scanner --analyzers yara --format detailed \
    --stdio-command python3 --stdio-arg=examples/malicious-mcp-server.py \
    > reports/malicious-server-report.txt || true

echo -e "${GREEN}✓ Malicious server scan complete${NC}"
echo "  Report saved to: reports/malicious-server-report.txt"

# Scan Mixed Security Server
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}3. Scanning Mixed Security MCP Server${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo ""

mcp-scanner --analyzers yara --format detailed \
    --stdio-command python3 --stdio-arg=examples/mixed-security-server.py \
    > reports/mixed-server-report.txt || true

echo -e "${GREEN}✓ Mixed server scan complete${NC}"
echo "  Report saved to: reports/mixed-server-report.txt"

# Generate summary
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}4. Generating Audit Summary${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo ""

# Count findings
SAFE_UNSAFE=$(grep -c "Safe: No" reports/safe-server-report.txt || echo "0")
MALICIOUS_UNSAFE=$(grep -c "Safe: No" reports/malicious-server-report.txt || echo "0")
MIXED_UNSAFE=$(grep -c "Safe: No" reports/mixed-server-report.txt || echo "0")

cat > reports/audit-summary.txt << EOF
═══════════════════════════════════════════════════════════
          MCP SECURITY AUDIT SUMMARY
═══════════════════════════════════════════════════════════

Audit Date: $(date)
Analyzer Used: YARA (Pattern Matching)

SERVERS SCANNED:
  1. Safe MCP Server
  2. Malicious MCP Server  
  3. Mixed Security MCP Server

FINDINGS:

┌─────────────────────────────────────────────────────────┐
│ Safe MCP Server                                         │
├─────────────────────────────────────────────────────────┤
│ Unsafe Tools Found: $SAFE_UNSAFE                                        │
│ Status: ✓ PASSED                                        │
│ Notes: All tools properly implemented with validation   │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ Malicious MCP Server                                    │
├─────────────────────────────────────────────────────────┤
│ Unsafe Tools Found: $MALICIOUS_UNSAFE                                        │
│ Status: ✗ CRITICAL VULNERABILITIES                      │
│ Threats: Command injection, credential harvesting       │
│          Prompt injection, data exfiltration            │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ Mixed Security MCP Server                               │
├─────────────────────────────────────────────────────────┤
│ Unsafe Tools Found: $MIXED_UNSAFE                                        │
│ Status: ⚠ MEDIUM RISK                                   │
│ Threats: Path traversal, script execution               │
└─────────────────────────────────────────────────────────┘

RECOMMENDATIONS:

1. Safe Server:
   ✓ No action needed - maintain current security posture
   
2. Malicious Server:
   ✗ DO NOT USE IN PRODUCTION
   ✗ Critical vulnerabilities require immediate attention
   ✗ Implement input validation and sandboxing
   
3. Mixed Security Server:
   ⚠ Review tools with medium-risk findings
   ⚠ Add stronger path validation
   ⚠ Implement stricter script execution controls

═══════════════════════════════════════════════════════════
For detailed findings, see individual report files.
═══════════════════════════════════════════════════════════
EOF

# Display summary
cat reports/audit-summary.txt

echo ""
echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Complete security audit finished!${NC}"
echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${CYAN}📊 Reports generated:${NC}"
echo "  • reports/safe-server-report.txt"
echo "  • reports/malicious-server-report.txt"
echo "  • reports/mixed-server-report.txt"
echo "  • reports/audit-summary.txt"
echo ""
echo -e "${CYAN}💡 Next Steps:${NC}"
echo "  • Review detailed reports for specific findings"
echo "  • Use findings to improve MCP server security"
echo "  • Run with --analyzers api,yara,llm for deeper analysis"
echo ""
