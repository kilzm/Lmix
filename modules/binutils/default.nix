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
  pkgName = "binutils";
})