{ stdenv
, lib
, pkg
, compiler
, compilerVer
} @args: 

import ../default.nix (args // {
  libName = "fftw3";
})
