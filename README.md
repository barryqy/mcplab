# MCP Scanner Lab

Hands-on security lab for learning Model Context Protocol (MCP) security using Cisco MCP Scanner.

## Overview

This lab teaches MCP security through direct hands-on experience with the `mcp-scanner` CLI tool. Students scan real MCP servers and see actual threat detection in action.

## Quick Start

### 1. Install MCP Scanner

```bash
# Install dependencies for Alpine/musl systems
apk add --no-cache python3-dev gcc musl-dev yara yara-dev build-base libffi-dev

# Clone and install
git clone https://github.com/cisco-ai-defense/mcp-scanner
cd mcp-scanner
pip install uv
uv venv venv
source venv/bin/activate

# Force build from source for musl compatibility
pip install --no-binary yara-python yara-python
uv pip install .

# Verify installation
mcp-scanner --version
```

### 2. Clone Lab Repository

```bash
git clone https://github.com/barryqy/mcplab
cd mcplab
pip install -r requirements.txt
```

### 3. Run Your First Scan

```bash
# Scan the safe MCP server
mcp-scanner --analyzers yara --format summary \
  --stdio-command python3 \
  --stdio-arg=examples/safe-mcp-server.py

# Scan the malicious MCP server
mcp-scanner --analyzers yara --format detailed \
  --stdio-command python3 \
  --stdio-arg=examples/malicious-mcp-server.py
```

## Lab Approach

**Direct CLI Usage** - No wrapper scripts! Students use `mcp-scanner` directly:

1. **Start an MCP server** (safe or malicious examples provided)
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

### Sample MCP Configurations

- **`example-configs/cursor-config.json`** - Cursor IDE MCP configuration
- **`example-configs/windsurf-config.json`** - Windsurf IDE configuration
- **`example-configs/claude-desktop-config.json`** - Claude Desktop configuration

## Lab Exercises

Full lab guide available at: [https://github.com/barryqy/llabsource-mcp](https://github.com/barryqy/llabsource-mcp)

### Exercise 1: Environment Validation
Verify `mcp-scanner` installation and available analyzers

### Exercise 2: Scan Safe Server
Scan a properly secured MCP server, learn what "safe" looks like

### Exercise 3: Scan Malicious Server
Detect command injection, credential harvesting, and data exfiltration

### Exercise 4: Scan Local Configurations
Audit MCP servers configured in your AI IDEs (Cursor/Windsurf/Claude)

## Key Features

### YARA Analyzer (No API Keys Required!)
- Pattern-based threat detection
- Detects: command injection, credential harvesting, system manipulation
- Works offline, no credentials needed
- Perfect for learning and development

### LLM Analyzer (Optional)
- Semantic analysis of tool behavior
- Detects: prompt injection, tool poisoning, intent manipulation
- Requires: OpenAI, AWS Bedrock, or compatible LLM API key

### API Analyzer (Optional - Enterprise)
- Cisco AI Defense threat intelligence
- Zero-day detection and compliance checking
- Requires: Cisco AI Defense subscription

## Example Commands

### Basic Scanning (Stdio Mode)

```bash
# Scan with YARA (no API key needed)
mcp-scanner --analyzers yara --format summary \
  --stdio-command python3 --stdio-arg=examples/safe-mcp-server.py

# Detailed output with findings
mcp-scanner --analyzers yara --format detailed \
  --stdio-command python3 --stdio-arg=examples/malicious-mcp-server.py

# Table format
mcp-scanner --analyzers yara --format table \
  --stdio-command python3 --stdio-arg=examples/malicious-mcp-server.py
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

### Scan Local Configurations

```bash
# Scan all known MCP configs (Cursor, Windsurf, Claude, etc.)
mcp-scanner --analyzers yara --format table --scan-known-configs
```

### With Multiple Analyzers

```bash
# Export API keys
export MCP_SCANNER_LLM_API_KEY="your-openai-key"
export MCP_SCANNER_API_KEY="your-cisco-api-key"

# Scan with all analyzers
mcp-scanner --analyzers yara,llm,api --format by_severity \
  --stdio-command python3 --stdio-arg=examples/malicious-mcp-server.py
```

## Requirements

- **Python 3.11 - 3.13** (Python 3.14+ not yet supported)
- **MCP Scanner** from [cisco-ai-defense/mcp-scanner](https://github.com/cisco-ai-defense/mcp-scanner)
- **No API credentials required** for YARA analyzer
- **Optional API keys** for LLM and API analyzers (advanced features)

### For Alpine Linux / musl Systems

Special installation required (see Quick Start above):
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
