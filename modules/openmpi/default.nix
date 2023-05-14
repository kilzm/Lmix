{ stdenv
, lib
, pkg
, compiler ? ""
, compilerVer ? 0
, jq
} @args:

import ../default.nix (args // {
  libName = "mpi";
  customPacName = "MPI";
  
  extraPkgVariables = builtins.toJSON {
    CXX_LIB = "${pkg}/lib -lmpi_cxx";
    F90_SHLIB = "${pkg}/lib -lmpi_mpifh";
    WWW = "https://doku.lrz.de/display/PUBLIC/OpenMPI";
  };
})
