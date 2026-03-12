#!/bin/bash

# Demo: Complete Security Audit
# This demo performs a comprehensive security audit of multiple MCP servers.

set -e

CI_MODE=0
JSON_MODE=0
SCAN_FAILURES=0

usage() {
    cat <<'EOF'
Usage: ./demo-complete-audit.sh [--ci-mode] [--json]

  --ci-mode   Skip the interactive pause and return non-zero when issues are found
  --json      Print a machine-readable summary to stdout (implies --ci-mode)
EOF
}

while [ $# -gt 0 ]; do
    case "$1" in
        --ci-mode)
            CI_MODE=1
            ;;
        --json)
            JSON_MODE=1
            CI_MODE=1
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage >&2
            exit 1
            ;;
    esac
    shift
done

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lab-env.sh"
cd "${SCRIPT_DIR}"

print_line() {
    if [ "$JSON_MODE" -eq 0 ]; then
        echo "$1"
    fi
}

print_color_line() {
    if [ "$JSON_MODE" -eq 0 ]; then
        echo -e "$1"
    fi
}

run_scan() {
    local step_title="$1"
    local example_path="$2"
    local report_path="$3"

    print_line ""
    print_color_line "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    print_color_line "${CYAN}${step_title}${NC}"
    print_color_line "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    print_line ""

    if mcp-scanner --analyzers yara --format detailed \
        --stdio-command python3 --stdio-args "$example_path" \
        > "$report_path" 2>&1; then
        print_color_line "${GREEN}✓ ${step_title#*. } complete${NC}"
        print_line "  Report saved to: $report_path"
        return
    fi

    SCAN_FAILURES=$((SCAN_FAILURES + 1))
    print_color_line "${RED}✗ ${step_title#*. } failed${NC}"
    print_line "  Check report for details: $report_path"
}

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

json_status_for_server() {
    local unsafe_count="$1"
    local server_name="$2"

    if [ "$unsafe_count" -eq 0 ]; then
        if [ "$server_name" = "mixed" ]; then
            echo "passed_with_review_note"
            return
        fi

        echo "passed"
        return
    fi

    if [ "$server_name" = "malicious" ]; then
        echo "critical"
        return
    fi

    echo "review_required"
}

write_text_summary() {
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

        if [ "$SCAN_FAILURES" -gt 0 ]; then
            echo "SCAN FAILURES:"
            echo "  ⚠ One or more scanner runs failed. Review the report files before trusting this summary."
            echo ""
        fi

        echo "═══════════════════════════════════════════════════════════"
        echo "For detailed findings, see individual report files."
        echo "═══════════════════════════════════════════════════════════"
    } > reports/audit-summary.txt
}

write_json_summary() {
    cat <<EOF
{
  "audit_date": "$(date)",
  "analyzer": "yara",
  "critical_count": ${TOTAL_UNSAFE},
  "unsafe_server_count": ${UNSAFE_SERVERS},
  "scan_failures": ${SCAN_FAILURES},
  "servers": [
    {
      "name": "safe",
      "unsafe_tools": ${SAFE_UNSAFE},
      "status": "$(json_status_for_server "$SAFE_UNSAFE" "safe")",
      "notes": "${SAFE_NOTES}"
    },
    {
      "name": "malicious",
      "unsafe_tools": ${MALICIOUS_UNSAFE},
      "status": "$(json_status_for_server "$MALICIOUS_UNSAFE" "malicious")",
      "notes": "${MALICIOUS_NOTES}; ${MALICIOUS_NOTES_2}"
    },
    {
      "name": "mixed",
      "unsafe_tools": ${MIXED_UNSAFE},
      "status": "$(json_status_for_server "$MIXED_UNSAFE" "mixed")",
      "notes": "${MIXED_NOTES}; ${MIXED_NOTES_2}"
    }
  ],
  "reports": [
    "reports/safe-server-report.txt",
    "reports/malicious-server-report.txt",
    "reports/mixed-server-report.txt",
    "reports/audit-summary.txt"
  ]
}
EOF
}

print_color_line "${CYAN}"
print_line "╔════════════════════════════════════════════════════════════╗"
print_line "║     MCP Scanner Demo - Complete Security Audit            ║"
print_line "╚════════════════════════════════════════════════════════════╝"
print_color_line "${NC}"

# Create reports directory
mkdir -p reports

print_color_line "${YELLOW}📋 This demo will:${NC}"
print_line "  1. Scan safe MCP server (baseline)"
print_line "  2. Scan malicious MCP server (vulnerabilities)"
print_line "  3. Scan mixed security server (realistic scenario)"
print_line "  4. Generate comprehensive security reports"
print_line ""

if [ "$CI_MODE" -eq 0 ]; then
    read -p "Press Enter to continue..."
fi

run_scan "1. Scanning Safe MCP Server" "examples/safe-mcp-server.py" "reports/safe-server-report.txt"
run_scan "2. Scanning Malicious MCP Server" "examples/malicious-mcp-server.py" "reports/malicious-server-report.txt"
run_scan "3. Scanning Mixed Security MCP Server" "examples/mixed-security-server.py" "reports/mixed-server-report.txt"

print_line ""
print_color_line "${CYAN}═══════════════════════════════════════════════════════════${NC}"
print_color_line "${CYAN}4. Generating Audit Summary${NC}"
print_color_line "${CYAN}═══════════════════════════════════════════════════════════${NC}"
print_line ""

SAFE_UNSAFE=$(count_unsafe_tools reports/safe-server-report.txt)
MALICIOUS_UNSAFE=$(count_unsafe_tools reports/malicious-server-report.txt)
MIXED_UNSAFE=$(count_unsafe_tools reports/mixed-server-report.txt)
TOTAL_UNSAFE=$((SAFE_UNSAFE + MALICIOUS_UNSAFE + MIXED_UNSAFE))
UNSAFE_SERVERS=0

if [ "$SAFE_UNSAFE" -gt 0 ]; then
    UNSAFE_SERVERS=$((UNSAFE_SERVERS + 1))
fi

if [ "$MALICIOUS_UNSAFE" -gt 0 ]; then
    UNSAFE_SERVERS=$((UNSAFE_SERVERS + 1))
fi

if [ "$MIXED_UNSAFE" -gt 0 ]; then
    UNSAFE_SERVERS=$((UNSAFE_SERVERS + 1))
fi

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

write_text_summary

if [ "$JSON_MODE" -eq 1 ]; then
    write_json_summary
else
    cat reports/audit-summary.txt

    print_line ""
    print_color_line "${GREEN}════════════════════════════════════════════════════════════${NC}"
    print_color_line "${GREEN}✅ Complete security audit finished!${NC}"
    print_color_line "${GREEN}════════════════════════════════════════════════════════════${NC}"
    print_line ""
    print_color_line "${CYAN}📊 Reports generated:${NC}"
    print_line "  • reports/safe-server-report.txt"
    print_line "  • reports/malicious-server-report.txt"
    print_line "  • reports/mixed-server-report.txt"
    print_line "  • reports/audit-summary.txt"
    print_line ""
    print_color_line "${CYAN}💡 Next Steps:${NC}"
    print_line "  • Review detailed reports for specific findings"
    print_line "  • Use findings to improve MCP server security"
    print_line "  • Run with --analyzers api,yara,llm for deeper analysis"
    print_line ""
fi

if [ "$CI_MODE" -eq 1 ] && { [ "$TOTAL_UNSAFE" -gt 0 ] || [ "$SCAN_FAILURES" -gt 0 ]; }; then
    exit 1
fi
