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
    --stdio-command python3 --stdio-args examples/safe-mcp-server.py \
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
    --stdio-command python3 --stdio-args examples/malicious-mcp-server.py \
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
    --stdio-command python3 --stdio-args examples/mixed-security-server.py \
    > reports/mixed-server-report.txt || true

echo -e "${GREEN}✓ Mixed server scan complete${NC}"
echo "  Report saved to: reports/mixed-server-report.txt"

# Generate summary
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}4. Generating Audit Summary${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo ""

# grep -c prints 0 but still exits non-zero when no matches are found.
# Swallow the exit code so the count stays a single clean value.
count_unsafe_tools() {
    local report_path="$1"
    local count

    count=$(grep -c "Safe: No" "$report_path" 2>/dev/null || true)
    if [ -z "$count" ]; then
        echo "0"
        return
    fi

    echo "$count"
}

SAFE_UNSAFE=$(count_unsafe_tools reports/safe-server-report.txt)
MALICIOUS_UNSAFE=$(count_unsafe_tools reports/malicious-server-report.txt)
MIXED_UNSAFE=$(count_unsafe_tools reports/mixed-server-report.txt)

if [ "$SAFE_UNSAFE" -eq 0 ]; then
    SAFE_STATUS="✓ PASSED"
    SAFE_NOTES="No YARA findings in current ruleset"
else
    SAFE_STATUS="⚠ REVIEW REQUIRED"
    SAFE_NOTES="Review the detailed report before using this server"
fi

if [ "$MALICIOUS_UNSAFE" -gt 0 ]; then
    MALICIOUS_STATUS="✗ CRITICAL VULNERABILITIES"
    MALICIOUS_NOTES="Command injection, credential harvesting"
    MALICIOUS_NOTES_2="Prompt injection, data exfiltration"
else
    MALICIOUS_STATUS="✓ PASSED"
    MALICIOUS_NOTES="No YARA findings in current ruleset"
    MALICIOUS_NOTES_2=""
fi

if [ "$MIXED_UNSAFE" -eq 0 ]; then
    MIXED_STATUS="✓ PASSED"
    MIXED_NOTES="No YARA findings in current ruleset"
    MIXED_NOTES_2="Manual review is still recommended"
else
    MIXED_STATUS="⚠ REVIEW REQUIRED"
    MIXED_NOTES="Inspect the detailed report for flagged tools"
    MIXED_NOTES_2="Tighten validation before production use"
fi

{
echo "═══════════════════════════════════════════════════════════"
echo "          MCP SECURITY AUDIT SUMMARY"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Audit Date: $(date)"
echo "Analyzer Used: YARA (Pattern Matching)"
echo ""
echo "SERVERS SCANNED:"
echo "  1. Safe MCP Server"
echo "  2. Malicious MCP Server  "
echo "  3. Mixed Security MCP Server"
echo ""
echo "FINDINGS:"
echo ""

echo "┌─────────────────────────────────────────────────────────┐"
printf '│ %-55s │\n' "Safe MCP Server"
echo "├─────────────────────────────────────────────────────────┤"
printf '│ %-55s │\n' "Unsafe Tools Found: $SAFE_UNSAFE"
printf '│ %-55s │\n' "Status: $SAFE_STATUS"
printf '│ %-55s │\n' "Notes: $SAFE_NOTES"
echo "└─────────────────────────────────────────────────────────┘"
echo ""

echo "┌─────────────────────────────────────────────────────────┐"
printf '│ %-55s │\n' "Malicious MCP Server"
echo "├─────────────────────────────────────────────────────────┤"
printf '│ %-55s │\n' "Unsafe Tools Found: $MALICIOUS_UNSAFE"
printf '│ %-55s │\n' "Status: $MALICIOUS_STATUS"
printf '│ %-55s │\n' "Threats: $MALICIOUS_NOTES"
printf '│ %-55s │\n' "$MALICIOUS_NOTES_2"
echo "└─────────────────────────────────────────────────────────┘"
echo ""

echo "┌─────────────────────────────────────────────────────────┐"
printf '│ %-55s │\n' "Mixed Security MCP Server"
echo "├─────────────────────────────────────────────────────────┤"
printf '│ %-55s │\n' "Unsafe Tools Found: $MIXED_UNSAFE"
printf '│ %-55s │\n' "Status: $MIXED_STATUS"
printf '│ %-55s │\n' "Notes: $MIXED_NOTES"
printf '│ %-55s │\n' "$MIXED_NOTES_2"
echo "└─────────────────────────────────────────────────────────┘"
echo ""
echo "RECOMMENDATIONS:"
echo ""
echo "1. Safe Server:"
echo "   ✓ Keep the current baseline and rescan after changes"
echo "   ✓ Review the report again after code updates"
echo ""
echo "2. Malicious Server:"
echo "   ✗ Do not use in production"
echo "   ✗ Critical vulnerabilities require immediate attention"
echo "   ✗ Implement input validation and sandboxing"
echo ""
echo "3. Mixed Security Server:"
echo "   ✓ No YARA findings in this run"
echo "   ⚠ Still review manually before production use"
echo "   ⚠ Add targeted tests for file and script handling"
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "For detailed findings, see individual report files."
echo "═══════════════════════════════════════════════════════════"
} > reports/audit-summary.txt

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
