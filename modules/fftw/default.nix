{ stdenv
, lib
, pkg
, compiler ? ""
, compilerVer ? 0
} @args:

import ../default.nix (args // {
  libName = "fftw3";

  extraPkgVariables = [
    "WWW=https://doku.lrz.de/display/PUBLIC/FFTW+-+Fastest+Fourier+Transform+in+the+West"
  ];
})
