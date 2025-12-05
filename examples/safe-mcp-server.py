#!/usr/bin/env python3
"""
Safe MCP Server Example

This server demonstrates properly implemented MCP tools with:
- Input validation
- No system command execution
- Clear, honest descriptions
- Proper error handling
"""

import asyncio
import json
from typing import Any
from mcp.server import Server
from mcp.types import Tool, TextContent


# Create server instance
app = Server("safe-mcp-server")


@app.list_tools()
async def list_tools() -> list[Tool]:
    """List all available tools."""
    return [
        Tool(
            name="get_weather",
            description="Get current weather information for a city. Returns temperature, conditions, and forecast.",
            inputSchema={
                "type": "object",
                "properties": {
                    "city": {
                        "type": "string",
                        "description": "City name to get weather for"
                    },
                    "units": {
                        "type": "string",
                        "enum": ["celsius", "fahrenheit"],
                        "description": "Temperature units",
                        "default": "celsius"
                    }
                },
                "required": ["city"]
            }
        ),
        Tool(
            name="calculate_sum",
            description="Calculate the sum of two numbers. Simple mathematical operation.",
            inputSchema={
                "type": "object",
                "properties": {
                    "a": {
                        "type": "number",
                        "description": "First number"
                    },
                    "b": {
                        "type": "number",
                        "description": "Second number"
                    }
                },
                "required": ["a", "b"]
            }
        ),
        Tool(
            name="search_docs",
            description="Search documentation for a specific topic. Returns relevant documentation sections.",
            inputSchema={
                "type": "object",
                "properties": {
                    "query": {
                        "type": "string",
                        "description": "Search query"
                    },
                    "limit": {
                        "type": "number",
                        "description": "Maximum number of results",
                        "default": 10
                    }
                },
                "required": ["query"]
            }
        )
    ]


@app.call_tool()
async def call_tool(name: str, arguments: Any) -> list[TextContent]:
    """Handle tool calls."""
    
    if name == "get_weather":
        city = arguments.get("city", "")
        units = arguments.get("units", "celsius")
        
        # Input validation
        if not city or not isinstance(city, str):
            return [TextContent(
                type="text",
                text="Error: City name is required and must be a string"
            )]
        
        # Simulate weather data (no actual API call)
        temp = 22 if units == "celsius" else 72
        result = {
            "city": city,
            "temperature": temp,
            "units": units,
            "conditions": "Partly cloudy",
            "forecast": "Sunny tomorrow"
        }
        
        return [TextContent(
            type="text",
            text=json.dumps(result, indent=2)
        )]
    
    elif name == "calculate_sum":
        a = arguments.get("a")
        b = arguments.get("b")
        
        # Input validation
        if not isinstance(a, (int, float)) or not isinstance(b, (int, float)):
            return [TextContent(
                type="text",
                text="Error: Both arguments must be numbers"
            )]
        
        result = {
            "a": a,
            "b": b,
            "sum": a + b
        }
        
        return [TextContent(
            type="text",
            text=json.dumps(result, indent=2)
        )]
    
    elif name == "search_docs":
        query = arguments.get("query", "")
        limit = arguments.get("limit", 10)
        
        # Input validation
        if not query or not isinstance(query, str):
            return [TextContent(
                type="text",
                text="Error: Query is required and must be a string"
            )]
        
        # Simulate search results (no actual search)
        results = [
            {
                "title": f"Documentation for {query}",
                "excerpt": f"This document explains how to use {query}...",
                "url": f"https://docs.example.com/{query.lower().replace(' ', '-')}"
            }
        ]
        
        return [TextContent(
            type="text",
            text=json.dumps(results[:limit], indent=2)
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

