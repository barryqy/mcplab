#!/usr/bin/env python3
"""
Generic HTTP/SSE Server Launcher for MCP Servers

This launcher converts any MCP stdio server to an HTTP/SSE endpoint.

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


def load_mcp_server(server_file: str):
    """Load an MCP server from a Python file."""
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
    
    # Get the MCP server instance (usually named 'app')
    if not hasattr(module, 'app'):
        print(f"❌ Error: No 'app' variable found in {server_file}")
        print("   Make sure your server file exports an MCP Server instance as 'app'")
        sys.exit(1)
    
    return module.app


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
    
    # Try using FastMCP if the server uses it
    try:
        from mcp.server.fastmcp import FastMCP
        
        # Load the server
        mcp_server = load_mcp_server(server_file)
        
        # Check if it's a FastMCP instance
        if isinstance(mcp_server, FastMCP):
            print("✅ Detected FastMCP server")
            app = mcp_server.sse_app()
        else:
            # Regular MCP Server - need to wrap it
            print("✅ Detected standard MCP Server")
            from mcp.server.sse import SseServerTransport
            from starlette.applications import Starlette
            from starlette.routing import Route
            
            sse = SseServerTransport("/messages")
            
            async def handle_sse(request):
                async with sse.connect_sse(
                    request.scope,
                    request.receive,
                    request._send
                ) as streams:
                    await mcp_server.run(
                        streams[0],
                        streams[1],
                        mcp_server.create_initialization_options()
                    )
            
            app = Starlette(
                routes=[
                    Route("/sse", endpoint=handle_sse),
                    Route("/messages", endpoint=handle_sse),
                ]
            )
    
    except ImportError as e:
        print(f"❌ Error: Missing dependency: {e}")
        print("   Install with: pip install fastmcp uvicorn starlette")
        sys.exit(1)
    
    print(f"📡 SSE endpoint: http://127.0.0.1:{port}/sse")
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

