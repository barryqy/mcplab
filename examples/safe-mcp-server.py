#!/usr/bin/env python3
"""
Safe MCP Server Example

This server demonstrates properly implemented MCP tools with:
- Input validation
- No system command execution
- Clear, honest descriptions
- Proper error handling
"""

import json
from mcp.server.fastmcp import FastMCP

# Create FastMCP server instance
mcp = FastMCP("safe-mcp-server")


@mcp.tool()
def get_weather(city: str, units: str = "celsius") -> str:
    """Get current weather information for a city. Returns temperature, conditions, and forecast."""
    # Input validation
    if not city or not isinstance(city, str):
        return "Error: City name is required and must be a string"
    
    if units not in ["celsius", "fahrenheit"]:
        return "Error: Units must be either 'celsius' or 'fahrenheit'"
    
    # Simulated weather data (safe, no external calls)
    weather_data = {
        "city": city,
        "temperature": 22 if units == "celsius" else 72,
        "units": units,
        "conditions": "Partly cloudy",
        "forecast": "Clear skies expected"
    }
    
    return json.dumps(weather_data, indent=2)


@mcp.tool()
def calculate_sum(a: float, b: float) -> str:
    """Calculate the sum of two numbers. Simple mathematical operation."""
    # Type validation (FastMCP handles this automatically via type hints)
    try:
        result = a + b
        return f"The sum of {a} and {b} is {result}"
    except Exception as e:
        return f"Calculation error: {str(e)}"


@mcp.tool()
def search_docs(query: str, limit: int = 10) -> str:
    """Search documentation for a specific topic. Returns relevant documentation sections."""
    # Input validation
    if not query or not isinstance(query, str):
        return "Error: Query is required and must be a string"
    
    if not isinstance(limit, int) or limit < 1 or limit > 100:
        return "Error: Limit must be between 1 and 100"
    
    # Simulated search results (safe, no external calls or file access)
    results = {
        "query": query,
        "limit": limit,
        "results": [
            {"title": f"Documentation for {query}", "relevance": 0.95},
            {"title": f"Guide to {query}", "relevance": 0.87},
            {"title": f"Best practices for {query}", "relevance": 0.76}
        ][:limit]
    }
    
    return json.dumps(results, indent=2)


# Run the server
if __name__ == "__main__":
    mcp.run()
