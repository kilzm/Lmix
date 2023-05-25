#!/bin/sh

# requires MODULEPATH set to /opt/modulefiles/modules-nix/modules
modpath=/opt/modulefiles
rm -f --preserve-root $modpath/*

# oneapi only builds with sandboxing disabled
nix build .#intel-oneapi_2022_2_0 --no-sandbox --no-link

modSuffixes=("-nixpkgs" "" "-intel")

for s in "${modSuffixes[@]}"; do
  nix profile install .#_modules$s --profile $modpath/modules-nix
done
