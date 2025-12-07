#!/usr/bin/env python3
"""
Generic HTTP/SSE Server Launcher for MCP Servers

This launcher converts any FastMCP server to an HTTP/SSE endpoint.

Usage:
    python3 launch_mcp_http.py <server-file.py> [port]

Examples:
    python3 launch_mcp_http.py examples/safe-mcp-server.py
    python3 launch_mcp_http.py examples/malicious-mcp-server.py 8001
"""

import sys
import os
import importlib.util
import uvicorn
from pathlib import Path


def load_fastmcp_server(server_file: str):
    """Load a FastMCP server from a Python file."""
    server_path = Path(server_file)
    
    if not server_path.exists():
        print(f"❌ Error: Server file not found: {server_file}")
        sys.exit(1)
    
    # Load the module from file
    spec = importlib.util.spec_from_file_location(
        server_path.stem.replace('-', '_'),
        server_path
    )
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    
    # Get the FastMCP instance (usually named 'mcp')
    if hasattr(module, 'mcp'):
        return module.mcp
    elif hasattr(module, 'app'):
        return module.app
    else:
        print(f"❌ Error: No 'mcp' or 'app' variable found in {server_file}")
        print("   Make sure your server file exports a FastMCP instance")
        sys.exit(1)


def main():
    """Main entry point"""
    if len(sys.argv) < 2:
        print("Usage: python3 launch_mcp_http.py <server-file.py> [port]")
        print()
        print("Examples:")
        print("  python3 launch_mcp_http.py examples/safe-mcp-server.py")
        print("  python3 launch_mcp_http.py examples/malicious-mcp-server.py 8001")
        sys.exit(1)
    
    server_file = sys.argv[1]
    port = int(sys.argv[2]) if len(sys.argv) > 2 else 8000
    
    print("=" * 70)
    print("🚀 MCP HTTP/SSE Server Launcher")
    print("=" * 70)
    print()
    print(f"📄 Server file: {server_file}")
    print(f"🔗 Port: {port}")
    print()
    
    try:
        from mcp.server.fastmcp import FastMCP
        
        # Load the FastMCP server
        mcp_server = load_fastmcp_server(server_file)
        
        if not isinstance(mcp_server, FastMCP):
            print(f"❌ Error: Server is not a FastMCP instance")
            print("   Update your server to use FastMCP for HTTP support")
            sys.exit(1)
        
        print("✅ Loaded FastMCP server")
        
        # Get the SSE app (FastMCP handles both /sse and /messages automatically)
        app = mcp_server.sse_app()
        
    except ImportError as e:
        print(f"❌ Error: Missing dependency: {e}")
        print("   Install with: pip install fastmcp uvicorn")
        sys.exit(1)
    except Exception as e:
        print(f"❌ Error loading server: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
    
    print(f"📡 SSE endpoint: http://127.0.0.1:{port}/sse")
    print(f"📬 Messages endpoint: http://127.0.0.1:{port}/messages")
    print()
    print("To scan this server, run:")
    print(f"  mcp-scanner --analyzers yara remote --server-url http://127.0.0.1:{port}/sse")
    print()
    print("Press Ctrl+C to stop")
    print("=" * 70)
    print()
    
    try:
        uvicorn.run(app, host="127.0.0.1", port=port, log_level="info")
    except KeyboardInterrupt:
        print("\n\n✅ Server stopped")
        sys.exit(0)
    except Exception as e:
        print(f"\n❌ Error starting server: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
