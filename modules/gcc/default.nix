{ stdenv
, lib
, buildEnv
, attrName
, pkg
, compiler ? ""
, compilerVer ? 0
, jq
} @args:

import ../default.nix (args // {
  # otherwise module name would be gcc-wrapper
  pkgName = "gcc";

  extraPkgVariables = builtins.toJSON {
    WWW = "https://doku.lrz.de/display/PUBLIC/GNU+Compiler+Collection";
  };
})
