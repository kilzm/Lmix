{ stdenv
, lib
, pkg
, buildEnv
, compiler ? ""
, compilerVer ? 0
, jq
} @args:

import ../../default.nix (args // {
  libPath = "lib/intel64/gcc4.8";
  libName = "tbb";

  customScriptPath = "${pkg}/env/vars.sh";

  excludes = [
    "PKG_CONFIG_PATH" # is set by the shell script
  ];
})
