import click
import sys
import subprocess
from pathlib import Path

@click.command()
@click.option('--dir', '-d', required=True, help='path to project directory')
def modules_to_flake(dir):
    """Generate a nix flake with a devShell derived from loaded modules"""
    path = Path(dir)
    if not path.exists():
        sys.exit("Error: path does not exist")

    if path.is_file():
        sys.exit("Error: path should be a directory (is a file)")

    if (path / 'flake.nix').exists():
        sys.exit("Error: directory is already a flake (remove flake.nix to override)")

        
    flake_new_cmd = ['nix', 'flake', 'new', '--template',  'github:kilzm/nix-with-modules', dir]
    
    try:
        subprocess.run(
            flake_new_cmd,
            encoding='utf-8',
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )

    except subprocess.CalledProcessError as e:
        sys.exit(f"Error: 'nix flake new' failed with code {e.returncode}: {e.stderr}")
