#!/usr/bin/env python3
"""
MCP Scanner Lab - Command-line Tool

Command-line interface for MCP Scanner lab exercises.
"""

import asyncio
import sys
import os
import argparse
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
    print_panel,
    console
)

from dotenv import load_dotenv


def check_environment() -> bool:
    """Check if environment is properly configured."""
    print_subheader("Exercise 1: Environment Validation")
    
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
    print_success("\n✅ Environment validation complete!")
    return True


async def scan_mcp_server(server_path: Path, exercise_name: str = "", description: str = ""):
    """Scan any MCP server - safe, malicious, or unknown.
    
    Args:
        server_path: Path to the MCP server to scan
        exercise_name: Optional exercise identifier for display
        description: Optional description to show before scanning
    """
    if exercise_name:
        print_subheader(exercise_name)
    
    if description:
        if "INTENTIONAL" in description.upper() or "DEMONSTRATION" in description.upper():
            print_warning(description)
        else:
            print_info(description)
    
    # Import scanner
    try:
        from mcpscanner import Config, Scanner
        from mcpscanner.core.models import AnalyzerEnum
        from mcpscanner.core.mcp_models import StdioServer
    except ImportError:
        print_error("MCP Scanner not installed")
        print_info("Run: pip install -r requirements.txt")
        return
    
    # Load environment variables
    load_dotenv()
    
    # Configure scanner
    config = Config()
    scanner = Scanner(config)
    
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
        
        print_success(f"\nScan complete! Found {len(results)} tools\n")
        
        safe_count = sum(1 for r in results if r.is_safe)
        unsafe_count = len(results) - safe_count
        
        # Display results
        for result in results:
            severity = result.severity if hasattr(result, 'severity') else 'UNKNOWN'
            status = "✓ SAFE" if result.is_safe else "✗ UNSAFE"
            color = "green" if result.is_safe else "red"
            
            console.print(f"  [{color}]{status}[/{color}] - {result.tool_name} ({severity})")
            
            # Show detected threats for unsafe tools
            if not result.is_safe and hasattr(result, 'findings') and result.findings:
                for finding in result.findings[:2]:  # Show first 2
                    threat_name = finding.threat_name if hasattr(finding, 'threat_name') else 'Unknown'
                    console.print(f"      • {threat_name}", style="yellow")
        
        print_info(f"\nResults: {safe_count} safe, {unsafe_count} unsafe")
        
        # Contextual summary
        if unsafe_count == 0:
            print_success("\n✅ All tools passed security checks!")
        else:
            print_warning(f"\n⚠️  Found {unsafe_count} unsafe tool(s) with security issues!")
        
    except Exception as e:
        print_error(f"Scan failed: {str(e)}")


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


async def scan_local_configs():
    """Exercise 4: Scan MCP configurations from known locations."""
    print_subheader("Exercise 4: Scan Local MCP Configurations")
    
    print_info("Searching for MCP configurations in well-known locations...")
    print_info("(Cursor, Windsurf, Claude Desktop, VS Code)")
    
    try:
        from mcpscanner import Config, Scanner
        from mcpscanner.core.models import AnalyzerEnum
    except ImportError:
        print_error("MCP Scanner not installed")
        print_info("Run: pip install -r requirements.txt")
        return
    
    load_dotenv()
    config = Config()
    scanner = Scanner(config)
    
    print_info("Using analyzers: YARA\n")
    
    try:
        results_dict = await scanner.scan_well_known_mcp_configs(
            analyzers=[AnalyzerEnum.YARA]
        )
        
        # Flatten the dictionary results into a list
        results = []
        for config_name, tool_results in results_dict.items():
            if tool_results:
                print_info(f"Found {len(tool_results)} tools in {config_name}")
                results.extend(tool_results)
        
        if not results:
            print_warning("No MCP configurations found on this system")
            print_info("\n💡 This is normal if you haven't configured Cursor, Windsurf, or Claude Desktop with MCP servers yet.")
            print_info("You can still learn from exercises 2 and 3!")
            return
        
        print_success(f"\nScan complete! Found {len(results)} tools across all configs\n")
        
        safe_count = sum(1 for r in results if r.is_safe)
        unsafe_count = len(results) - safe_count
        
        for result in results:
            status = "✓ SAFE" if result.is_safe else "✗ UNSAFE"
            color = "green" if result.is_safe else "red"
            severity = result.severity if hasattr(result, 'severity') else 'UNKNOWN'
            
            console.print(f"  [{color}]{status}[/{color}] - {result.tool_name} ({severity})")
        
        print_info(f"\nResults: {safe_count} safe, {unsafe_count} unsafe")
        
        if unsafe_count > 0:
            print_warning("\n⚠️  Found unsafe tools in your local configurations!")
            print_info("Review and remove any untrusted MCP servers from your AI IDE configurations.")
        else:
            print_success("\n✅ All configured MCP tools appear safe!")
        
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


def main():
    """Main entry point with CLI argument parsing."""
    parser = argparse.ArgumentParser(
        description="MCP Scanner Lab - Interactive Security Testing Tool",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python3 mcp_lab.py --exercise1-environment-validation
  python3 mcp_lab.py --exercise2-scan-safe-server
  python3 mcp_lab.py --exercise3-scan-malicious-server
  python3 mcp_lab.py --exercise4-scan-local-configs
  python3 mcp_lab.py --about
        """
    )
    
    parser.add_argument(
        '--exercise1-environment-validation',
        action='store_true',
        help='Exercise 1: Validate environment setup'
    )
    
    parser.add_argument(
        '--exercise2-scan-safe-server',
        action='store_true',
        help='Exercise 2: Scan a safe MCP server'
    )
    
    parser.add_argument(
        '--exercise3-scan-malicious-server',
        action='store_true',
        help='Exercise 3: Scan a malicious MCP server'
    )
    
    parser.add_argument(
        '--exercise4-scan-local-configs',
        action='store_true',
        help='Exercise 4: Scan local MCP configurations'
    )
    
    parser.add_argument(
        '--about',
        action='store_true',
        help='Show information about MCP Scanner'
    )
    
    args = parser.parse_args()
    
    # Show header
    print_header("MCP Scanner Lab")
    
    # Execute the requested exercise
    try:
        if args.exercise1_environment_validation:
            check_environment()
        elif args.exercise2_scan_safe_server:
            asyncio.run(exercise2_scan_safe_server())
        elif args.exercise3_scan_malicious_server:
            asyncio.run(exercise3_scan_malicious_server())
        elif args.exercise4_scan_local_configs:
            asyncio.run(scan_local_configs())
        elif args.about:
            show_about()
        else:
            # No argument provided, show help
            parser.print_help()
            print("\n")
            print_info("💡 Run an exercise by providing one of the options above")
            print_info("Example: python3 mcp_lab.py --exercise1-environment-validation")
            
    except KeyboardInterrupt:
        print("\n")
        print_warning("Interrupted by user")
        sys.exit(0)
    except Exception as e:
        print_error(f"Error: {str(e)}")
        sys.exit(1)


if __name__ == "__main__":
    main()
