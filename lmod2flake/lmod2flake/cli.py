import click
import subprocess
import os
from pathlib import Path
from lmod.spider import Spider

def exit_err(msg: str, context):
    click.echo(click.style('error: ', fg='red') + msg, err=True)
    context.exit(1)

LMIX_FLAKE =  "github:kilzm/lmix"

COMPILERS = [
    'gcc8', 'gcc9', 'gcc10', 'gcc11', 'gcc12',
    'intel21', 'intel23', 'intel21IFort'
]

@click.command()
@click.pass_context
@click.argument("directory", required=True)
@click.option("-c", "--compiler", type=click.Choice(COMPILERS))
@click.option("-b", "--build-tools", multiple=True, type=click.Choice(['pkg-config', 'cmake', 'autotools', 'bear']))
def modules_to_flake(ctx, directory, compiler, build_tools):
    """Generate a nix flake with a devShell derived from loaded modules"""
    path = Path(directory)
    flake_path = Path(directory) / "flake.nix"
    if not path.exists():
        exit_err("path does not exist", ctx)

    if path.is_file():
        exit_err("path should be a directory (is a file)", ctx)

    if flake_path.exists():
        exit_err("directory is already a flake (remove flake.nix to override)", ctx)

    flake_new_cmd = ['nix', 'flake', 'new', '--template',  f'{LMIX_FLAKE}#lmod2flake', path]
    
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
    BUILDINPUTS_LINE = "buildInputs = "
    NATIVEBUILDINPUTS_LINE = "nativeBuildInputs = "

    with flake_path.open(mode='r') as flake:
        flake_lines = list(map (str.strip, flake.read().splitlines()))
        if compiler != None:
            ds_idx = next(i for i, l in enumerate(flake_lines) if l.startswith(DEVSHELL_LINE)) + 1
            flake_lines[ds_idx:ds_idx] = [ f"stdenv = pkgs.lmix-pkgs.{compiler}Stdenv;" ]
        bi_idx = next(i for i, l in enumerate(flake_lines) if l.startswith(BUILDINPUTS_LINE)) + 1
        flake_lines[bi_idx:bi_idx] = build_inputs() 
        nbi_idx = next(i for i, l in enumerate(flake_lines) if l.startswith(NATIVEBUILDINPUTS_LINE)) + 1
        flake_lines[nbi_idx:nbi_idx] = native_build_inputs(build_tools)

        
    with flake_path.open(mode='w') as flake:
        flake.write('\n'.join(flake_lines))

    nixpkgs_fmt_cmd = ['nix', 'shell', f'{LMIX_FLAKE}#formatter', '-c', 'nixpkgs-fmt', f'{flake_path}']
    
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


NIX_MODULES_PATH = "/opt/modulefiles/modules-nix/modules"
COMPILER_MODULES = ["gcc", "intel-oneapi-compilers", "gfortran", "intel-oneapi-ifort" ]
def build_inputs():
    spider = Spider(NIX_MODULES_PATH)
    modules = [module for module in spider.get_names() if module != 'nix-stdenv']
    inputs = [ ]
    for module in modules:
        if module in COMPILER_MODULES: continue
        env_var = f"LMIX_ATTRNAME_{module.replace('-','_').upper()}"
        if env_var in os.environ:
            inputs.append(os.environ[env_var])
    return inputs

def native_build_inputs(build_tools: tuple):
    if build_tools == (): return []
    inputs = [ ]
    for tool in list(build_tools):
        match(tool):
            case "cmake":
                inputs.append("cmake")
            case "pkg-config":
                inputs.append("pkg-config")
            case "autotools":
                inputs.extend(["autoconf", "automake", "libtool"])
            case "bear":
                inputs.append("bear")
    return inputs
