{ stdenv
, lib
, pkg
, compiler ? ""
, compilerVer ? 0
, jq
} @args:

import ../../default.nix (args // {
  inheritModulefile = "${pkg}/modulefiles/compiler";

  extraPkgVariables = builtins.toJSON {
    BIN = "${pkg}/linux/bin";
    BIN_INTEL64 = "${pkg}/linux/bin/intel64";
  };
})
