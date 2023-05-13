#!/bin/sh

# requires MODULEPATH set to /opt/modulefiles/modules-nix/modules
modpath=/opt/modulefiles
rm -f $modpath/*

nix profile install .#modules --profile $modpath/modules-nix

export NIXPKGS_ALLOW_UNFREE=1 # intel software uses unfree license (EULA)
export NIXPKGS_ALLOW_INSECURE=1 # oneapi needs qt515.full to build which has insecure component qt-webtoolkit
 # oneapi only builds with sandboxing disabled
 # --impure is needed so nix can read the environment variables for unfree and insecure
nix build --impure .#intel-oneapi_2022_2_0 --no-sandbox --no-link
nix profile install --impure .#modules-intel --profile $modpath/modules-nix
export NIXPKGS_ALLOW_UNFREE=0
export NIXPKGS_ALLOW_INSECURE=0
