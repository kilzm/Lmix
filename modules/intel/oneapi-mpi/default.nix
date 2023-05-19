{ stdenv
, lib
, buildEnv
, pkg
, compiler ? ""
, compilerVer ? 0
, jq
} @args:

with lib;
with lib.strings;
let 
  isGCC = compiler == "gcc";
  isIntel = compiler == "intel";
  cc = ""
    + optionalString isGCC "gcc"
    + optionalString isIntel "icc";
  cxx = ""
    + optionalString isGCC "g++"
    + optionalString isIntel "icpc";
in
import ../../default.nix (args // {
  libName = "mpi";
  libPath = "lib/release";
  
  dependencies = []
    ++ optional isGCC "gcc/${builtins.toString compilerVer}";

  extraEnvVariables = builtins.toJSON {
    I_MPI_CC = "${cc}";
    I_MPI_CXX = "${cxx}";
  };

  customScriptPath = "${pkg}/env/vars.sh";
})

