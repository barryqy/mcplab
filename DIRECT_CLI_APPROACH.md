# MCP Scanner Lab - Quick Reference

## Direct CLI Approach

Students use `mcp-scanner` CLI directly - no wrapper scripts, completely transparent and authentic!

---

## Exercise 1: Scan Safe Server

```bash
cd /home/developer/src/mcplab

mcp-scanner --analyzers yara --format detailed \
  --stdio-command python3 \
  --stdio-arg=examples/safe-mcp-server.py
```

**Expected:** All tools SAFE, 0 findings

**Note:** mcp-scanner automatically starts the server, scans it, and shuts it down.

---

## Exercise 2: Scan Malicious Server

### Method A: Stdio (Simple)

```bash
cd /home/developer/src/mcplab

mcp-scanner --analyzers yara --format detailed \
  --stdio-command python3 \
  --stdio-arg=examples/malicious-mcp-server.py
```

**Expected:** Multiple HIGH severity findings

### Method B: Remote HTTP (Production-like)

```bash
# Install dependencies
pip install fastmcp uvicorn starlette

# Start server in background
python3 launch_mcp_http.py examples/malicious-mcp-server.py > /tmp/mcp-http-server.log 2>&1 &
echo $! > /tmp/mcp-http-server.pid
sleep 3

# Scan it
mcp-scanner --analyzers yara --format detailed \
  remote --server-url http://127.0.0.1:8000/sse

# Stop server
kill $(cat /tmp/mcp-http-server.pid) && rm /tmp/mcp-http-server.pid /tmp/mcp-http-server.log
```

**Expected:** Identical results to Method A

**Note:** `launch_mcp_http.py` works with any MCP server:
```bash
python3 launch_mcp_http.py examples/safe-mcp-server.py
python3 launch_mcp_http.py examples/malicious-mcp-server.py 8001  # custom port
```

---

## Exercise 3: Scan Local Configs

```bash
mcp-scanner --analyzers yara --format table --scan-known-configs
```

**Scans:** Cursor, Windsurf, Claude Desktop configurations

---

## Alternative Formats

```bash
# Summary view
mcp-scanner --analyzers yara --format summary \
  --stdio-command python3 --stdio-arg=examples/safe-mcp-server.py

# Table view
mcp-scanner --analyzers yara --format table \
  --stdio-command python3 --stdio-arg=examples/malicious-mcp-server.py

# By severity
mcp-scanner --analyzers yara --format by_severity \
  --stdio-command python3 --stdio-arg=examples/malicious-mcp-server.py

# JSON output
mcp-scanner --analyzers yara --format raw \
  --stdio-command python3 --stdio-arg=examples/safe-mcp-server.py
```

---

## With Multiple Analyzers (if configured)

```bash
# Set environment
export MCP_SCANNER_LLM_API_KEY="your-key"
export MCP_SCANNER_LLM_MODEL="gpt-4o"

# Scan with YARA + LLM
mcp-scanner --analyzers yara,llm --format detailed \
  --stdio-command python3 --stdio-arg=examples/malicious-mcp-server.py
```

---

## Why This Approach?

✅ **Authentic**: Real mcp-scanner CLI, not a wrapper  
✅ **Transparent**: Students see exactly what's running  
✅ **Educational**: Learn actual tool usage  
✅ **Credible**: Real security scanning, not simulated  
✅ **Practical**: Skills transfer to real-world use

---

## Troubleshooting

### Scanner not found
```bash
pip install cisco-ai-mcp-scanner
mcp-scanner --version
```

### No output or errors
- Check file paths are correct (use absolute paths if needed)
- Verify Python 3.11+ is being used: `python3 --version`
- Make sure examples directory exists

### Permission denied
```bash
chmod +x examples/*.py
```

