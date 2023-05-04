#!/bin/sh

sandboxTrue() {
  sed -i 's/sandbox = false/sandbox = true/g' /etc/nix/nix.conf
}

sandboxFalse() {

  sed -i 's/sandbox = true/sandbox = false/g' /etc/nix/nix.conf
}

# requires MODULEPATH set to /opt/modulefiles/modules-nix/modules
modpath=/opt/modulefiles
rm -f $modpath/*

sandboxTrue
nix profile install .#modules --profile $modpath/modules-nix

sandboxFalse
export NIXPKGS_ALLOW_UNFREE=1
export NIXPKGS_ALLOW_INSECURE=1
nix profile install --impure .#modules-intel --profile $modpath/modules-nix
export NIXPKGS_ALLOW_UNFREE=0
export NIXPKGS_ALLOW_INSECURE=0
sandboxTrue
