{ stdenv
, lib
, pkg
, compiler ? ""
, compilerVer ? 0
} @args:

import ../default.nix (args // {
  # otherwise module name would be gcc-wrapper
  pkgName = "gcc";

  extraPkgVariables = [
    "WWW=https://doku.lrz.de/display/PUBLIC/GNU+Compiler+Collection"
  ];
})
