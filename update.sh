#!/bin/sh

# requires MODULEPATH set to /opt/modulefiles/modules-nix/modules
modpath=/opt/modulefiles
rm -f $modpath/*

nix profile install .#modules --profile $modpath/modules-nix

nix profile install .#modules-nixpkgs --profile $modpath/modules-nix

 # oneapi only builds with sandboxing disabled
nix build .#intel-oneapi_2022_2_0 --no-sandbox --no-link
nix profile install .#modules-intel --profile $modpath/modules-nix
