# lmix
A pure and reproducible nix overlay for HPC-packages. It is able to automatically generate [LMod](https://lmod.readthedocs.io) modulefiles written in Lua. The idea is to bridge the gap between the old standard of environment modules and a more sophisticated approach with the nix package manager.

## Installation
For best reproducibility use of flakes is highly recommended. [Flakes](https://nixos.wiki/wiki/Flakes) need to be enabled first.

### Installing everything including modules
Clone the repository and run the update script: `./update.sh`. This will build all the required packages. The modulefiles will be installed to `/opt/modulefiles/modules-nix/modules`. Make sure the `MODULEPATH` variable is correctly set to include this path.

### Building individual packages
Running `$ nix flake show` gives an overview of custom packages defined in this overlay. To build one use:
```
$ nix build .#<name>
```
The attributes prefixed with `_modules` are environments including many packages and the corresponding modulefiles.

### Old style overlay
This approach has worse reproducibility due to nixpkgs being dependent on your local version instead of the pinned one from `flake.lock`.
Put this into `~/.config/nixpkgs/overlays.nix`:
```nix
[ (import (builtins.fetchTarball "https://github.com/kilzm/lmix/archive/master.tar.gz")) ]
```
Then you can build packages defined in the overlay using
```
$ nix build --impure nixpkgs#lmix-pkgs.<name>
```


### Usage in a flake
A neat feature of flakes is that you can use them as inputs in other flakes. This allows you to configure a nix development shell with the dependencies for the project including packages of this overlay:
```nix
{
  description = "Flake that uses lmix overlay";

  inputs.lmix.url = github:kilzm/lmix;

  outputs = { self, lmix }:
    let
      system = "x86_64-linux";
      pkgs = lmix.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell.override { 
        # stdenv = pkgs.lmix-pkgs.<stdenv>  
      } rec {
        buildInputs = with pkgs; [
          # required packages go here
        ];
        nativeBuildInputs = with pkgs; [
          # build packages go here
        ];
      };
    };
}
```
All packages put inside the buildInputs list will be made availible in the devShell.
An easy way to get started is running this command which will put the above flake template into your current directory.
```
$ nix flake init --template github:kilzm/lmix
```
Once the packages are configured run `$ nix develop` to start a shell session with all the listed packages in `PATH`.

## lmod2flake

Flakes like the one above can be created automatically.
```
$ nix run github:kilzm/lmix -- <path>
```
This will create a flake.nix in the specified directory. The buildInputs for mkShell will be derived from loaded modules.
