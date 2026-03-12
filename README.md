# MCP Scanner Lab

Hands-on security lab for learning Model Context Protocol (MCP) security using Cisco MCP Scanner.

## Overview

This lab teaches MCP security through direct hands-on experience with the `mcp-scanner` CLI tool. Students scan real MCP servers and see actual threat detection in action.

## Quick Start

### 1. Install MCP Scanner

```bash
# Clone and install
git clone https://github.com/cisco-ai-defense/mcp-scanner
cd mcp-scanner

# Install uv if you don't have it
pip install uv

# Create a virtual environment with Python 3.13
export PATH="$HOME/.local/bin:$PATH"
uv venv --python 3.13
source .venv/bin/activate

uv pip install .

# Verify installation
mcp-scanner --version
```

### 2. Clone Lab Repository

```bash
cd /home/developer/src
git clone https://github.com/barryqy/mcplab
cd mcplab
uv pip install -r requirements.txt
```

If you want to run the Module 4 LLM exercises manually, load the helper first:

```bash
source ./lab-env.sh
```

### 3. Run Your First Scan

```bash
# Scan the safe MCP server
mcp-scanner --analyzers yara --format table \
  --stdio-command python3 \
  --stdio-args examples/safe-mcp-server.py

# Scan the malicious MCP server
mcp-scanner --analyzers yara --format table \
  --stdio-command python3 \
  --stdio-args examples/malicious-mcp-server.py
```

## Lab Approach

**Direct CLI Usage** - The core exercises use `mcp-scanner` directly, then Module 5 adds demo scripts for automation patterns:

1. **Point `mcp-scanner` at a provided server example**
2. **Run mcp-scanner** against it with real CLI commands
3. **See actual threat detection** from YARA patterns
4. **Learn real-world tool usage** that transfers to production

This approach is:
- ✅ **Authentic** - Real security scanning, not simulated
- ✅ **Transparent** - Students see exactly what's happening
- ✅ **Educational** - Learn actual command-line usage
- ✅ **Practical** - Skills apply directly to real-world scenarios

## What's Included

### Example MCP Servers

- **`examples/safe-mcp-server.py`** - Properly secured server (input validation, no dangerous patterns)
- **`examples/malicious-mcp-server.py`** - Intentionally vulnerable (command injection, credential harvesting)
- **`examples/prompt-injection-server.py`** - Server with dangerous prompts
- **`examples/mixed-security-server.py`** - Mix of safe and unsafe tools

### Demo Scripts

- **`demo-prompt-scanning.sh`** - Prompt scanning walkthrough
- **`demo-api-scanning.sh`** - REST API workflow demo
- **`demo-complete-audit.sh`** - Multi-server audit with report output

## Lab Exercises

Full lab guide available at: [https://github.com/barryqy/llabsource-mcp](https://github.com/barryqy/llabsource-mcp)

### Exercise 1: Environment Validation
Verify `mcp-scanner` installation and available analyzers

### Exercise 2: Scan Safe Server
Scan a properly secured MCP server, learn what "safe" looks like

### Exercise 3: Scan Malicious Server
Detect command injection, credential harvesting, and data exfiltration

## Key Features

### YARA Analyzer (No API Keys Required!)
- Pattern-based threat detection
- Detects: command injection, credential harvesting, system manipulation
- Works offline, no credentials needed
- Perfect for learning and development

### LLM Analyzer (Optional)
- Semantic analysis of tool behavior
- Detects: prompt injection, tool poisoning, intent manipulation
- `lab-env.sh` prepares the LLM settings used in this lab
- Outside the lab, use any OpenAI-compatible, Bedrock, or other supported LLM endpoint

### API Analyzer (Optional - Enterprise)
- Cisco AI Defense threat intelligence
- Zero-day detection and compliance checking
- Requires: Cisco AI Defense subscription

## Example Commands

### Basic Scanning (Stdio Mode)

```bash
# Scan with YARA (no API key needed)
mcp-scanner --analyzers yara --format summary \
  --stdio-command python3 --stdio-args examples/safe-mcp-server.py

# Detailed output with findings
mcp-scanner --analyzers yara --format detailed \
  --stdio-command python3 --stdio-args examples/malicious-mcp-server.py

# Table format
mcp-scanner --analyzers yara --format table \
  --stdio-command python3 --stdio-args examples/malicious-mcp-server.py
```

### HTTP/SSE Server Scanning

Start any MCP server as HTTP endpoint using the included launcher:

```bash
# Start server
python3 launch_mcp_http.py examples/malicious-mcp-server.py &

# Scan it
mcp-scanner --analyzers yara --format detailed \
  remote --server-url http://127.0.0.1:8000/sse

# Works with any server file
python3 launch_mcp_http.py examples/safe-mcp-server.py 8001  # custom port
```

### With Multiple Analyzers

```bash
# Load the helper used for the LLM exercises
source ./lab-env.sh

# Scan with multiple analyzers
mcp-scanner --analyzers yara,llm --format by_severity \
  --stdio-command python3 --stdio-args examples/malicious-mcp-server.py

# Optional: add Cisco AI Defense API analyzer credentials
export MCP_SCANNER_API_KEY="your-cisco-api-key"
```

## Requirements

- **Python 3.13** recommended for this lab
- **MCP Scanner** from [cisco-ai-defense/mcp-scanner](https://github.com/cisco-ai-defense/mcp-scanner)
- **No API credentials required** for YARA analyzer
- **LLM configuration** for the LLM analyzer exercises
- **Optional API key** for Cisco AI Defense API analyzer

### For Alpine Linux / musl Systems

Special installation may be required:
```bash
apk add python3-dev gcc musl-dev yara yara-dev build-base libffi-dev
pip install --no-binary yara-python yara-python
```

## Detected Threat Categories

- **Command Injection**: `subprocess`, `os.system`, shell execution
- **Credential Harvesting**: Environment variables, API keys, secrets
- **System Manipulation**: File access, path traversal, privilege escalation
- **Data Exfiltration**: External network requests, data transmission
- **Script Injection**: SQL injection, code injection, template injection
- **Prompt Injection**: LLM manipulation, system prompt override

## Support

**Questions or Issues?**  
Contact Barry Yuan at bayuan@cisco.com

## License

Apache 2.0

## Learn More

- **MCP Scanner**: https://github.com/cisco-ai-defense/mcp-scanner
- **Lab Modules**: https://github.com/barryqy/llabsource-mcp
- **Cisco AI Defense**: https://www.cisco.com/site/us/en/products/security/ai-defense/
