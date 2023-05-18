{ stdenv
, lib
, pkg
, compiler ? ""
, compilerVer ? 0
, jq
} @args:

import ../../default.nix (args // {
  libPath = "lib/intel64/gcc4.8";
  libName = "tbb";

  inheritModulefile = "${pkg}/modulefiles/tbb";
})
