{ stdenv
, lib
, pkg
, compiler ? ""
, compilerVer ? 0
, jq
} @args:

import ../default.nix (args // rec {
  libName = "ruby-${pkg.version.majMinTiny}";
  incPath = "include/ruby-${pkg.version.majMin}.0";
})
