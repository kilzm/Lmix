import click
import subprocess
import os
from pathlib import Path
from lmod.spider import Spider

def exit_err(msg: str, context):
    click.echo(click.style('error: ', fg='red') + msg, err=True)
    context.exit(1)

NIX_WITH_MODUES_FLAKE = "github:kilzm/nix-with-modules"

COMPILERS = {
    'gcc7': ['gcc7', 'gfortran7'],
    'gcc8': ['gcc8', 'gfortran8'],
    'gcc9': ['gcc9', 'gfortran9'],
    'gcc10': ['gcc10', 'gfortran10'],
    'gcc11': ['gcc11', 'gfortran11'],
    'gcc12': ['gcc12', 'gfortran12'],
    'intel21': ['nwm-pkgs.intel-compilers_2022_1_0']
}

@click.command()
@click.pass_context
@click.argument("directory", required=True)
@click.option("-c", "--compiler", type=click.Choice(list(COMPILERS)))
@click.option("-b", "--build-tools", multiple=True, type=click.Choice(['pkg-config', 'cmake', 'autotools']))
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
        flake_lines[ds_idx:ds_idx] = build_inputs(compiler) + native_build_inputs(build_tools) + env_variables(compiler)
        
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


NIX_MODULES_PATH = "/opt/modulefiles/modules-nix/modules"
COMPILER_MODULES = ["gcc", "intel-oneapi-compilers"]
def build_inputs(compiler):
    spider = Spider(NIX_MODULES_PATH)
    modules = [module for module in spider.get_names() if module != 'nix-stdenv']
    inputs = [ "buildInputs = with pkgs; [", "# compiler "] + COMPILERS[compiler] + [ "# other" ]
    for module in modules:
        if module in COMPILER_MODULES: continue
        env_var = f"NIXWM_ATTRNAME_{module.replace('-','_').upper()}"
        if env_var in os.environ:
            inputs.append(os.environ[env_var])
    inputs.append("];")
    return inputs

def native_build_inputs(build_tools: tuple):
    if build_tools == (): return []
    inputs = [ "nativeBuildInputs = with pkgs; [" ]
    for tool in list(build_tools):
        match(tool):
            case "cmake":
                inputs.append("cmake")
            case "pkg-config":
                inputs.append("pkg-config")
            case "autotools":
                inputs.extend(["autoconf", "automake", "libtool"])
            case _: pass
    inputs.append("];")
    return inputs

def env_variables(compiler):
    CC, CXX, FC = ('"gcc"', '"g++"', '"gfortran"') if compiler.startswith("gcc") else (
                  ('"icc"', '"icpc"', '"ifort"') if compiler.startswith("intel") else (
                  ("", "", "")))
    return [
        f"CC = {CC};",
        f"CXX = {CXX};",
        f"FC = {FC};",
    ]
