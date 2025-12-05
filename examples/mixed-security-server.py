#!/usr/bin/env python3
"""
Mixed Security MCP Server Example

This server demonstrates a realistic scenario with:
- Some safe tools
- Some tools with medium-severity issues
- Demonstrates realistic security assessment scenarios
"""

import asyncio
import json
import os
from typing import Any
from mcp.server import Server
from mcp.types import Tool, TextContent


# Create server instance
app = Server("mixed-security-server")


@app.list_tools()
async def list_tools() -> list[Tool]:
    """List all available tools."""
    return [
        Tool(
            name="safe_echo",
            description="Safely echo back the provided text",
            inputSchema={
                "type": "object",
                "properties": {
                    "text": {
                        "type": "string",
                        "description": "Text to echo"
                    }
                },
                "required": ["text"]
            }
        ),
        Tool(
            name="list_files",
            description="List files in a directory (restricted to safe paths)",
            inputSchema={
                "type": "object",
                "properties": {
                    "path": {
                        "type": "string",
                        "description": "Directory path to list",
                        "default": "."
                    }
                },
                "required": []
            }
        ),
        Tool(
            name="format_json",
            description="Format JSON data with pretty printing",
            inputSchema={
                "type": "object",
                "properties": {
                    "data": {
                        "type": "string",
                        "description": "JSON string to format"
                    }
                },
                "required": ["data"]
            }
        ),
        Tool(
            name="read_file",
            description="Read contents of a file (MEDIUM RISK: Limited path validation)",
            inputSchema={
                "type": "object",
                "properties": {
                    "path": {
                        "type": "string",
                        "description": "File path to read"
                    }
                },
                "required": ["path"]
            }
        ),
        Tool(
            name="run_script",
            description="Run a predefined script (MEDIUM RISK: Limited script selection)",
            inputSchema={
                "type": "object",
                "properties": {
                    "script_name": {
                        "type": "string",
                        "description": "Name of the script to run",
                        "enum": ["backup", "cleanup", "report"]
                    }
                },
                "required": ["script_name"]
            }
        )
    ]


@app.call_tool()
async def call_tool(name: str, arguments: Any) -> list[TextContent]:
    """Handle tool calls."""
    
    if name == "safe_echo":
        text = arguments.get("text", "")
        
        # Properly validated and safe
        if not isinstance(text, str):
            return [TextContent(
                type="text",
                text="Error: Text must be a string"
            )]
        
        return [TextContent(
            type="text",
            text=f"Echo: {text}"
        )]
    
    elif name == "list_files":
        path = arguments.get("path", ".")
        
        # Some validation, but could be improved
        if ".." in path or path.startswith("/"):
            return [TextContent(
                type="text",
                text="Error: Path traversal not allowed"
            )]
        
        try:
            files = os.listdir(path)
            result = {"path": path, "files": files}
            return [TextContent(
                type="text",
                text=json.dumps(result, indent=2)
            )]
        except Exception as e:
            return [TextContent(
                type="text",
                text=f"Error listing files: {str(e)}"
            )]
    
    elif name == "format_json":
        data = arguments.get("data", "")
        
        # Safe JSON formatting
        try:
            parsed = json.loads(data)
            formatted = json.dumps(parsed, indent=2)
            return [TextContent(
                type="text",
                text=formatted
            )]
        except json.JSONDecodeError as e:
            return [TextContent(
                type="text",
                text=f"Invalid JSON: {str(e)}"
            )]
    
    elif name == "read_file":
        path = arguments.get("path", "")
        
        # MEDIUM RISK: Basic path validation but could be bypassed
        # Allows reading any file with insufficient restrictions
        if not path or ".." in path:
            return [TextContent(
                type="text",
                text="Error: Invalid path"
            )]
        
        try:
            with open(path, 'r') as f:
                content = f.read()
            
            return [TextContent(
                type="text",
                text=f"Contents of {path}:\n{content}"
            )]
        except Exception as e:
            return [TextContent(
                type="text",
                text=f"Error reading file: {str(e)}"
            )]
    
    elif name == "run_script":
        script_name = arguments.get("script_name", "")
        
        # MEDIUM RISK: Limited to enum but still executes scripts
        allowed_scripts = ["backup", "cleanup", "report"]
        
        if script_name not in allowed_scripts:
            return [TextContent(
                type="text",
                text=f"Error: Script must be one of {allowed_scripts}"
            )]
        
        # Simulated script execution
        result = {
            "script": script_name,
            "status": "executed",
            "output": f"Script '{script_name}' completed successfully"
        }
        
        return [TextContent(
            type="text",
            text=json.dumps(result, indent=2)
        )]
    
    else:
        return [TextContent(
            type="text",
            text=f"Error: Unknown tool '{name}'"
        )]


async def main():
    """Run the server."""
    from mcp.server.stdio import stdio_server
    
    async with stdio_server() as (read_stream, write_stream):
        await app.run(
            read_stream,
            write_stream,
            app.create_initialization_options()
        )


if __name__ == "__main__":
    asyncio.run(main())

