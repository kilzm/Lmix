#!/bin/sh

# requires MODULEPATH set to /opt/modulefiles/modules-nix/modules

modpath=/opt/modulefiles
rm -f $modpath/*

nix profile install .#modules --profile $modpath/modules-nix
