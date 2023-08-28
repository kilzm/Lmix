#!/bin/sh

# requires MODULEPATH set to /opt/modulefiles/modules-nix/${pkgs-ver}
modpath=/opt/modulefiles

if [[ -d "${modpath}/modules_nix" ]]; then
  nix profile remove --profile ${modpath}/modules_nix '.*'
fi

nix profile install .#_modules .#_modules-nixpkgs --profile $modpath/modules_nix