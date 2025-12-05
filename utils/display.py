"""
Utility functions for displaying formatted output in the terminal.
"""

from rich.console import Console
from rich.table import Table
from rich.panel import Panel
from rich.text import Text
from rich import box

console = Console()


def print_header(text: str) -> None:
    """Print a formatted section header."""
    console.print(f"\n[bold cyan]{'=' * 60}[/bold cyan]")
    console.print(f"[bold cyan]{text.center(60)}[/bold cyan]")
    console.print(f"[bold cyan]{'=' * 60}[/bold cyan]\n")


def print_subheader(text: str) -> None:
    """Print a formatted subsection header."""
    console.print(f"\n[bold yellow]{text}[/bold yellow]")
    console.print(f"[yellow]{'-' * len(text)}[/yellow]")


def print_success(message: str) -> None:
    """Print a success message."""
    console.print(f"[green]✓[/green] {message}")


def print_error(message: str) -> None:
    """Print an error message."""
    console.print(f"[red]✗[/red] {message}")


def print_warning(message: str) -> None:
    """Print a warning message."""
    console.print(f"[yellow]⚠[/yellow] {message}")


def print_info(message: str) -> None:
    """Print an info message."""
    console.print(f"[blue]ℹ[/blue] {message}")


def print_progress(message: str) -> None:
    """Print a progress indicator."""
    console.print(f"[cyan]🔄[/cyan] {message}")


def print_security_result(result: dict) -> None:
    """
    Print formatted security scan results.
    
    Args:
        result: Dictionary containing scan results with keys:
                - tool_name: Name of the scanned tool
                - is_safe: Boolean indicating if tool is safe
                - severity: Severity level (SAFE, LOW, MEDIUM, HIGH, CRITICAL)
                - threats: List of detected threats
                - analyzers: Dict of analyzer results
    """
    tool_name = result.get('tool_name', 'Unknown')
    is_safe = result.get('is_safe', True)
    severity = result.get('severity', 'UNKNOWN')
    
    # Color based on severity
    if is_safe or severity == 'SAFE':
        color = 'green'
        icon = '✓'
    elif severity in ['LOW', 'MEDIUM']:
        color = 'yellow'
        icon = '⚠'
    else:  # HIGH, CRITICAL
        color = 'red'
        icon = '✗'
    
    console.print(f"\n[bold]{icon} Tool: {tool_name}[/bold]")
    console.print(f"  Status: [{color}]{severity}[/{color}]")
    
    # Print analyzer results if available
    if 'analyzers' in result:
        console.print("  Analyzer Results:")
        for analyzer, analyzer_result in result['analyzers'].items():
            analyzer_severity = analyzer_result.get('severity', 'UNKNOWN')
            console.print(f"    • {analyzer}: {analyzer_severity}")
    
    # Print threats if any
    if 'threats' in result and result['threats']:
        console.print("  Detected Threats:")
        for threat in result['threats']:
            console.print(f"    • {threat}")


def print_table(data: list, title: str = None) -> None:
    """
    Print data as a formatted table.
    
    Args:
        data: List of dictionaries with consistent keys
        title: Optional table title
    """
    if not data:
        print_warning("No data to display")
        return
    
    # Create table
    table = Table(title=title, box=box.ROUNDED)
    
    # Add columns based on first row keys
    for key in data[0].keys():
        table.add_column(key.replace('_', ' ').title(), style="cyan")
    
    # Add rows
    for row in data:
        table.add_row(*[str(v) for v in row.values()])
    
    console.print(table)


def print_panel(content: str, title: str = None, border_style: str = "blue") -> None:
    """
    Print content in a bordered panel.
    
    Args:
        content: Content to display
        title: Optional panel title
        border_style: Color of the border
    """
    console.print(Panel(content, title=title, border_style=border_style))


def print_menu(options: dict) -> None:
    """
    Print a formatted menu.
    
    Args:
        options: Dictionary mapping option numbers/keys to descriptions
    """
    console.print("\n[bold cyan]Menu Options:[/bold cyan]")
    for key, description in options.items():
        console.print(f"  [yellow]{key}[/yellow]. {description}")
    console.print()

