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
  libName = "fftw3";

  extraPkgVariables = builtins.toJSON {
    WWW = "https://doku.lrz.de/display/PUBLIC/FFTW+-+Fastest+Fourier+Transform+in+the+West";
  };
})
