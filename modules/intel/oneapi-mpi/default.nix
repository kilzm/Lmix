{ lib, pkg, cc, ... }:
with lib;
let
  isGCC = strings.hasPrefix "gcc" cc;
  isIntel = strings.hasPrefix "intel" cc;
  CC = if isGCC then "gcc" else (if isIntel then "icc" else "");
  CXX = if isGCC then "g++" else (if isIntel then "icpc" else "");
  module = if isGCC then let ver = strings.removePrefix "gcc" cc; in "gcc/${ver}"
  else let ver = strings.removePrefix "intel" cc; in "intel-oneapi-compilers/20${ver}";
in
{
  libName = "mpi";
  libPath = "lib/release";

  customPacName = "MPI";

  dependencies = [ module ];

  conflicts = [
    "openmpi"
  ];

  extraEnvVariables = builtins.toJSON {
    I_MPI_CC = "${CC}";
    I_MPI_CXX = "${CXX}";
    I_MPI_ROOT = "${pkg}";
  };
}

