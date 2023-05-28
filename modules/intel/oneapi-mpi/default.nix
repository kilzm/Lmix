{ lib, pkg, cc, ... }:
with lib;
let
  isGCC = strings.hasPrefix "gcc" cc;
  isIntel = strings.hasPrefix "intel" cc;
  CC = if isGCC then "gcc" else "icc";
  CXX = if isGCC then "g++" else "icpc";
  module = if isGCC then let ver = strings.removePrefix "gcc" cc; in "gcc/${ver}"
  else let ver = strings.removePrefix "intel" cc; in "intel-oneapi-compilers/${ver}";
in
{
  libName = "mpi";
  libPath = "lib/release";

  dependencies = [ module ];

  extraEnvVariables = builtins.toJSON {
    I_MPI_CC = "${CC}";
    I_MPI_CXX = "${CXX}";
  };

  customScriptPath = "${pkg}/env/vars.sh";
}

