# MCP Lab Refactoring - Generic Scanner Function

## Issue
The original function names `scan_safe_server()` and `scan_malicious_server()` made it seem like the results were predetermined or fake, undermining the credibility of the security scanning.

## Solution
Refactored to use a single generic `scan_mcp_server()` function that doesn't know or care whether the server is safe or malicious - it just scans and reports what it finds.

## Changes Made

### Before: Separate Functions for Safe/Malicious

```python
async def scan_safe_server():
    """Scan the safe MCP server."""
    print_subheader("Exercise 2: Scan Safe MCP Server")
    print_info("This server contains only safe, properly validated tools")
    # ... scanning logic ...

async def scan_malicious_server():
    """Scan the malicious MCP server."""
    print_subheader("Exercise 3: Scan Malicious MCP Server")
    print_warning("This server contains INTENTIONAL vulnerabilities")
    # ... duplicate scanning logic ...
```

**Problems:**
- Function names telegraph the expected results
- Looks predetermined/fake
- Duplicate code in both functions
- Undermines educational value

### After: Generic Scanner Function

```python
async def scan_mcp_server(server_path: Path, exercise_name: str = "", description: str = ""):
    """Scan any MCP server - safe, malicious, or unknown.
    
    Args:
        server_path: Path to the MCP server to scan
        exercise_name: Optional exercise identifier for display
        description: Optional description to show before scanning
    """
    # ... single unified scanning logic ...
    # Results determined by actual scan, not function name

async def exercise2_scan_safe_server():
    """Exercise 2: Scan a properly secured MCP server."""
    server_path = Path(__file__).parent / "examples" / "safe-mcp-server.py"
    await scan_mcp_server(
        server_path=server_path,
        exercise_name="Exercise 2: Scan Safe MCP Server",
        description="Scanning example server with security best practices"
    )

async def exercise3_scan_malicious_server():
    """Exercise 3: Scan a vulnerable MCP server."""
    server_path = Path(__file__).parent / "examples" / "malicious-mcp-server.py"
    await scan_mcp_server(
        server_path=server_path,
        exercise_name="Exercise 3: Scan Malicious MCP Server",
        description="This server contains INTENTIONAL vulnerabilities for demonstration"
    )
```

**Benefits:**
✅ Generic function doesn't know what it's scanning  
✅ Results determined by actual security scan  
✅ No duplicate code  
✅ More credible and educational  
✅ Reusable for any MCP server  
✅ Exercise wrapper functions provide context  

## Key Design Principles

### 1. Separation of Concerns

- **`scan_mcp_server()`**: Generic scanner, no assumptions
- **`exercise2_scan_safe_server()`**: Provides exercise context
- **`exercise3_scan_malicious_server()`**: Provides exercise context

### 2. Neutral Naming

- Function names don't telegraph results
- "scan" not "verify safe" or "detect malicious"
- Results speak for themselves

### 3. Contextual Descriptions

```python
# Exercise functions provide context WITHOUT biasing results
description="Scanning example server with security best practices"  # Not "safe server"
description="This server contains INTENTIONAL vulnerabilities for demonstration"  # Warning, not assumption
```

### 4. Result-Driven Output

```python
# Scanner reports what it finds, not what it expects
if unsafe_count == 0:
    print_success("\n✅ All tools passed security checks!")
else:
    print_warning(f"\n⚠️  Found {unsafe_count} unsafe tool(s) with security issues!")
```

## Code Improvements

### Eliminated Duplication

**Before:** ~80 lines duplicated between safe and malicious functions  
**After:** Single 75-line function used by both exercises

### Smart Description Handling

```python
if "INTENTIONAL" in description.upper() or "DEMONSTRATION" in description.upper():
    print_warning(description)  # Yellow warning for demo/lab servers
else:
    print_info(description)  # Blue info for regular descriptions
```

### Unified Result Display

```python
# Same code displays results regardless of server type
for result in results:
    status = "✓ SAFE" if result.is_safe else "✗ UNSAFE"
    color = "green" if result.is_safe else "red"
    console.print(f"  [{color}]{status}[/{color}] - {result.tool_name} ({severity})")
```

## Educational Value

### Students See Real Scanning

1. **Exercise 2**: Scanner finds no threats → reports "all safe"
2. **Exercise 3**: Scanner finds threats → reports "X unsafe tools"
3. **Same scanner**, different results based on actual findings

### Builds Trust

- Function doesn't "know" what server it's scanning
- Results come from actual YARA pattern matching
- Students see the scanner working objectively

### Enables Extension

Students/instructors can easily add new exercises:

```python
async def exercise5_scan_custom_server():
    """Scan a custom MCP server."""
    server_path = Path("/path/to/custom-server.py")
    await scan_mcp_server(
        server_path=server_path,
        exercise_name="Exercise 5: Your Custom Server",
        description="Scanning custom MCP implementation"
    )
```

## Testing

All functionality preserved, just better organized:

```bash
# Exercise 2 - Scans safe server, reports safe
python3 mcp_lab.py --exercise2-scan-safe-server

# Exercise 3 - Scans malicious server, reports threats
python3 mcp_lab.py --exercise3-scan-malicious-server

# Same scanner function, different inputs, different results
```

## Summary

✅ More credible - generic scanner doesn't assume results  
✅ More educational - students see real security scanning  
✅ More maintainable - no duplicate code  
✅ More extensible - easy to add new exercises  
✅ More professional - proper separation of concerns  

The scanner now demonstrates genuine security analysis rather than appearing to be a predetermined demonstration.

