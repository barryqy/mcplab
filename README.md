# MCP Scanner Lab

Interactive hands-on lab for learning MCP security with Cisco MCP Scanner.

## Quick Start

1. Install MCP Scanner:
   ```bash
   git clone https://github.com/cisco-ai-defense/mcp-scanner
   cd mcp-scanner
   pip install uv
   uv venv venv
   source venv/bin/activate
   uv pip install .
   ```

2. Clone this repository:
   ```bash
   git clone https://github.com/barryqy/mcplab
   cd mcplab
   ```

3. Initialize lab environment:
   ```bash
   chmod +x 0-init-lab.sh
   ./0-init-lab.sh
   ```
   
   **Note**: The lab works immediately with YARA analyzer (no API keys required). Credentials are optional for advanced features.

4. Run the interactive lab tool:
   ```bash
   python3 mcp_lab.py
   ```

## Lab Modules

Follow the lab modules at: [https://github.com/barryqy/llabsource-mcp](https://github.com/barryqy/llabsource-mcp)

## What's Included

- **Interactive lab tool** with menu-driven interface
- **Pre-built example MCP servers** (safe and malicious)
- **Automated demo scripts** for various scenarios
- **Sample MCP configurations** for testing

## Demo Scripts

- `demo-prompt-scanning.sh` - Scan MCP prompts for injection attacks
- `demo-api-scanning.sh` - Test REST API endpoints
- `demo-complete-audit.sh` - Full security audit workflow

## Example MCP Servers

- `examples/safe-mcp-server.py` - Clean, secure MCP server
- `examples/malicious-mcp-server.py` - Server with vulnerabilities
- `examples/prompt-injection-server.py` - Server with dangerous prompts
- `examples/mixed-security-server.py` - Mixed safe/unsafe tools

## Requirements

- Python 3.11 or higher (but less than 3.14)
- MCP Scanner installed (from https://github.com/cisco-ai-defense/mcp-scanner)
- **No API credentials required** - YARA analyzer works out of the box
- Optional: Your own API keys for LLM/API analyzers (advanced features)

## Support

Questions? Contact Barry Yuan at bayuan@cisco.com

## License

Apache 2.0

