#!/bin/sh

# require MODULEPATH set to /opt/modulefiles/modules-nix/modules

modpath=/opt/modulefiles
rm $modpath/*

nix profile install .#modules --profile $modpath/modules-nix
