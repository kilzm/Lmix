import click
import subprocess
import os
from pathlib import Path
from lmod2flake.modulecmd import ModuleCmd

def exit_err(msg: str, context):
    click.echo(click.style('error: ', fg='red') + msg, err=True)
    context.exit(1)

NIX_WITH_MODUES_FLAKE = "github:kilzm/nix-with-modules"

@click.command()
@click.pass_context
@click.argument("directory", required=True)
def modules_to_flake(ctx, directory):
    """Generate a nix flake with a devShell derived from loaded modules"""
    path = Path(directory)
    flake_path = Path(directory) / "flake.nix"
    if not path.exists():
        exit_err("path does not exist", ctx)

    if path.is_file():
        exit_err("path should be a directory (is a file)", ctx)

    if flake_path.exists():
        exit_err("directory is already a flake (remove flake.nix to override)", ctx)

    flake_new_cmd = ['nix', 'flake', 'new', '--template',  f'{NIX_WITH_MODUES_FLAKE}#no-build-inputs', path]
    
    try:
        subprocess.run(
            flake_new_cmd,
            encoding='utf-8',
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )

    except subprocess.CalledProcessError as e:
        exit_err(f"'nix flake new' failed with code {e.returncode}: {e.stderr}", ctx)
    
    DEVSHELL_LINE = "devShells.${system}.default"

    with flake_path.open(mode='r') as flake:
        flake_lines = list(map (str.strip, flake.read().splitlines()))
        ds_idx = next(i for i, l in enumerate(flake_lines) if l.startswith(DEVSHELL_LINE)) + 1
        flake_lines[ds_idx:ds_idx] = get_build_inputs()
        
    with flake_path.open(mode='w') as flake:
        flake.write('\n'.join(flake_lines))

    nixpkgs_fmt_cmd = ['nix', 'shell', f'{NIX_WITH_MODUES_FLAKE}#formatter', '-c', 'nixpkgs-fmt', f'{flake_path}']
    
    try:
        subprocess.run(
            nixpkgs_fmt_cmd,
            encoding='utf-8',
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )

    except subprocess.CalledProcessError as e:
        exit_err(f"'nix shell' failed with code {e.returncode}: {e.stderr}", ctx)

def get_build_inputs():
    ml = ModuleCmd()
    modules = [mod for mod in ml.list() if mod != 'nix-stdenv']
    inputs = [ "buildInputs = with pkgs; [" ]
    for module in modules:
        env_var = f"NIXWM_ATTRNAME_{module.split('/')[0].upper().replace('-','_')}"
        if env_var not in os.environ:
            print(f"attribute name for {module} not found")
            continue
        inputs.append(os.environ[env_var])
    inputs.append("];")
    return inputs
