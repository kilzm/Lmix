{ stdenv
, lib
, pkg
, compiler ? ""
, compilerVer ? 0
, jq
} @args:

import ../default.nix (args // rec {
  libName = "python${lib.versions.majorMinor pkg.version}";
  pkgName = "python";

  incPath = "include/${libName}";
  
  extraPkgVariables = builtins.toJSON {
    WWW = "https://doku.lrz.de/display/PUBLIC/Python+for+HPC";
  };
})
