{ stdenv
, lib
, buildEnv
, attrName
, pkg
, compiler ? ""
, compilerVer ? 0
, jq
} @args:

import ../../default.nix (args // {
  customScriptPath = "${pkg}/env/vars.sh";

  dependencies = [
    "intel-oneapi-tbb"
  ];

  excludes = [
    "LIBDIR"
  ];

  extraPkgVariables = builtins.toJSON {
    BIN = "${pkg}/linux/bin";
    BIN_INTEL64 = "${pkg}/linux/bin/intel64";
  };
})
