# MCP Scanner Lab - Quick Reference

## Setup

```bash
cd /home/developer/src/mcplab
pip install -r requirements.txt
```

## Commands

### Get Help
```bash
python3 mcp_lab.py --help
```

### Exercise 1: Validate Environment
```bash
python3 mcp_lab.py --exercise1-environment-validation
```
**What it does**: Checks MCP Scanner installation and analyzer availability

### Exercise 2: Scan Safe Server
```bash
python3 mcp_lab.py --exercise2-scan-safe-server
```
**What it does**: Scans a properly secured MCP server

### Exercise 3: Scan Malicious Server
```bash
python3 mcp_lab.py --exercise3-scan-malicious-server
```
**What it does**: Scans a vulnerable MCP server with security threats

### Exercise 4: Scan Local Configs
```bash
python3 mcp_lab.py --exercise4-scan-local-configs
```
**What it does**: Scans MCP configurations from Cursor/Windsurf/Claude Desktop

### About MCP Scanner
```bash
python3 mcp_lab.py --about
```
**What it does**: Shows information about MCP Scanner's capabilities

## Troubleshooting

### ModuleNotFoundError: No module named 'rich'
```bash
pip install -r requirements.txt
```

### Scanner not found
```bash
pip install cisco-ai-mcp-scanner
```

### Permission denied
```bash
chmod +x mcp_lab.py
```

## Example Lab Flow

```bash
# Step 1: Validate setup
python3 mcp_lab.py --exercise1-environment-validation

# Step 2: Learn from safe server
python3 mcp_lab.py --exercise2-scan-safe-server

# Step 3: See threat detection
python3 mcp_lab.py --exercise3-scan-malicious-server

# Step 4: Scan your own configs
python3 mcp_lab.py --exercise4-scan-local-configs
```

## Key Features

✅ No interactive menus - direct command execution  
✅ Copy/paste commands from lab guide  
✅ Each exercise runs independently  
✅ Clear, consistent output format  
✅ Built-in help system  

## Support

Questions? Contact Barry at bayuan@cisco.com

