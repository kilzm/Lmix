#!/bin/sh

# requires MODULEPATH set to /opt/modulefiles/modules-nix/modules
modpath=/opt/modulefiles
rm -f $modpath/modules-nix*

modSuffixes=("-nixpkgs" "")

for s in "${modSuffixes[@]}"; do
  nix profile install .#_modules$s --profile $modpath/modules-nix
done