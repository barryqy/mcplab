#!/usr/bin/env python3
"""
MCP Scanner Lab - Interactive Tool

Main menu-driven interface for MCP Scanner lab exercises.
"""

import asyncio
import sys
import os
from pathlib import Path

# Add utils to path
sys.path.insert(0, str(Path(__file__).parent))

from utils.display import (
    print_header,
    print_subheader,
    print_success,
    print_error,
    print_warning,
    print_info,
    print_menu,
    print_panel,
    console
)

from rich.prompt import Prompt
from dotenv import load_dotenv
import os


def check_environment() -> bool:
    """Check if environment is properly configured."""
    print_subheader("Environment Validation")
    
    # Load .env file
    if not Path(".env").exists():
        print_warning(".env file not found")
        print_info("Run ./0-init-lab.sh to create it (optional)")
    else:
        load_dotenv()
        print_success(".env file found")
    
    # Check which analyzers are available
    print_info("\nAvailable Analyzers:")
    print_success("✓ YARA - Pattern matching (always available)")
    
    if os.getenv("MCP_SCANNER_LLM_API_KEY"):
        print_success("✓ LLM - AI-powered analysis (configured)")
        print_info(f"  Model: {os.getenv('MCP_SCANNER_LLM_MODEL', 'Not set')}")
    else:
        print_warning("⚠ LLM - Not configured (add MCP_SCANNER_LLM_API_KEY to .env)")
    
    if os.getenv("MCP_SCANNER_API_KEY"):
        print_success("✓ API - Cisco AI Defense (configured)")
        print_info(f"  Endpoint: {os.getenv('MCP_SCANNER_ENDPOINT', 'Not set')}")
    else:
        print_warning("⚠ API - Not configured (add MCP_SCANNER_API_KEY to .env)")
    
    print_info("\n💡 YARA analyzer works without any credentials!")
    return True


async def scan_safe_server():
    """Scan the safe MCP server."""
    print_subheader("Scanning Safe MCP Server")
    
    print_info("Starting safe-mcp-server...")
    print_info("This server contains only safe, properly validated tools")
    
    # Import here to avoid loading if not needed
    try:
        from mcpscanner import Config, Scanner
        from mcpscanner.core.models import AnalyzerEnum
        from mcpscanner.core.mcp_models import StdioServer
    except ImportError:
        print_error("MCP Scanner not installed")
        print_info("Run: pip install cisco-ai-mcp-scanner")
        return
    
    # Load environment variables
    load_dotenv()
    
    # Configure scanner
    config = Config()
    scanner = Scanner(config)
    
    # Scan the safe server (stdio)
    server_path = Path(__file__).parent / "examples" / "safe-mcp-server.py"
    
    print_info(f"Scanning: {server_path}")
    print_info("Using analyzers: YARA")
    
    try:
        # Create StdioServer configuration
        server_config = StdioServer(
            command="python3",
            args=[str(server_path)]
        )
        
        results = await scanner.scan_stdio_server_tools(
            server_config=server_config,
            analyzers=[AnalyzerEnum.YARA]
        )
        
        print_success(f"Scan complete! Found {len(results)} tools")
        
        for result in results:
            severity = result.severity if hasattr(result, 'severity') else 'UNKNOWN'
            status = "✓ SAFE" if result.is_safe else "✗ UNSAFE"
            color = "green" if result.is_safe else "red"
            
            console.print(f"  [{color}]{status}[/{color}] - {result.tool_name} ({severity})")
        
    except Exception as e:
        print_error(f"Scan failed: {str(e)}")


async def scan_malicious_server():
    """Scan the malicious MCP server."""
    print_subheader("Scanning Malicious MCP Server")
    
    print_warning("This server contains INTENTIONAL vulnerabilities for demonstration")
    
    try:
        from mcpscanner import Config, Scanner
        from mcpscanner.core.models import AnalyzerEnum
        from mcpscanner.core.mcp_models import StdioServer
    except ImportError:
        print_error("MCP Scanner not installed")
        return
    
    load_dotenv()
    config = Config()
    scanner = Scanner(config)
    
    server_path = Path(__file__).parent / "examples" / "malicious-mcp-server.py"
    
    print_info(f"Scanning: {server_path}")
    print_info("Using analyzers: YARA")
    
    try:
        # Create StdioServer configuration
        server_config = StdioServer(
            command="python3",
            args=[str(server_path)]
        )
        
        results = await scanner.scan_stdio_server_tools(
            server_config=server_config,
            analyzers=[AnalyzerEnum.YARA]
        )
        
        print_success(f"Scan complete! Found {len(results)} tools")
        
        unsafe_count = sum(1 for r in results if not r.is_safe)
        
        if unsafe_count > 0:
            print_error(f"⚠ Found {unsafe_count} unsafe tools!")
        
        for result in results:
            severity = result.severity if hasattr(result, 'severity') else 'UNKNOWN'
            status = "✓ SAFE" if result.is_safe else "✗ UNSAFE"
            color = "green" if result.is_safe else "red"
            
            console.print(f"  [{color}]{status}[/{color}] - {result.tool_name} ({severity})")
            
            # Show detected threats
            if hasattr(result, 'findings') and result.findings:
                for finding in result.findings[:2]:  # Show first 2
                    threat_name = finding.threat_name if hasattr(finding, 'threat_name') else 'Unknown'
                    console.print(f"      • {threat_name}", style="yellow")
        
    except Exception as e:
        print_error(f"Scan failed: {str(e)}")


async def scan_local_configs():
    """Scan MCP configurations from known locations."""
    print_subheader("Scanning Local MCP Configurations")
    
    print_info("Searching for MCP configurations in well-known locations...")
    
    try:
        from mcpscanner import Config, Scanner
        from mcpscanner.core.models import AnalyzerEnum
    except ImportError:
        print_error("MCP Scanner not installed")
        return
    
    load_dotenv()
    config = Config()
    scanner = Scanner(config)
    
    print_info("Using analyzers: YARA")
    
    try:
        results = await scanner.scan_known_configs(
            analyzers=[AnalyzerEnum.YARA]
        )
        
        if not results:
            print_warning("No MCP configurations found on this system")
            print_info("You can scan example configs with mcp-scanner CLI")
            return
        
        print_success(f"Scan complete! Found {len(results)} tools")
        
        for result in results:
            status = "✓ SAFE" if result.is_safe else "✗ UNSAFE"
            color = "green" if result.is_safe else "red"
            severity = result.severity if hasattr(result, 'severity') else 'UNKNOWN'
            
            console.print(f"  [{color}]{status}[/{color}] - {result.tool_name} ({severity})")
        
    except Exception as e:
        print_error(f"Scan failed: {str(e)}")


def show_about():
    """Show information about MCP Scanner."""
    print_subheader("About MCP Scanner")
    
    about_text = """
[bold cyan]MCP Scanner[/bold cyan] - Security Scanner for Model Context Protocol

[yellow]Three Detection Engines:[/yellow]

[cyan]1. YARA Analyzer[/cyan] (Pattern Matching)
   • Fast, offline detection
   • Known malicious patterns
   • Command injection, credential harvesting

[cyan]2. LLM Analyzer[/cyan] (Semantic Analysis)
   • Deep understanding of tool behavior
   • Context-aware threat detection
   • Prompt injection, tool poisoning

[cyan]3. API Analyzer[/cyan] (Enterprise Intelligence)
   • Cisco Talos threat intelligence
   • Zero-day detection
   • Compliance checking

[yellow]Supported Threat Categories:[/yellow]
   • Command Injection
   • Prompt Injection
   • Credential Harvesting
   • System Manipulation
   • Data Exfiltration
   • Tool Poisoning

[green]Learn more:[/green] https://github.com/cisco-ai-defense/mcp-scanner
    """
    
    print_panel(about_text.strip(), title="MCP Scanner", border_style="cyan")


def main_menu():
    """Display and handle main menu."""
    
    while True:
        print_header("MCP Scanner Lab - Interactive Tool")
        
        options = {
            "1": "Validate Environment",
            "2": "Scan Safe MCP Server",
            "3": "Scan Malicious MCP Server",
            "4": "Scan Local MCP Configurations",
            "5": "About MCP Scanner",
            "0": "Exit"
        }
        
        print_menu(options)
        
        choice = Prompt.ask("Select an option", choices=list(options.keys()), default="0")
        
        if choice == "0":
            print_success("Goodbye!")
            break
        elif choice == "1":
            check_environment()
            input("\nPress Enter to continue...")
        elif choice == "2":
            asyncio.run(scan_safe_server())
            input("\nPress Enter to continue...")
        elif choice == "3":
            asyncio.run(scan_malicious_server())
            input("\nPress Enter to continue...")
        elif choice == "4":
            asyncio.run(scan_local_configs())
            input("\nPress Enter to continue...")
        elif choice == "5":
            show_about()
            input("\nPress Enter to continue...")


if __name__ == "__main__":
    try:
        main_menu()
    except KeyboardInterrupt:
        print("\n")
        print_warning("Interrupted by user")
        sys.exit(0)

