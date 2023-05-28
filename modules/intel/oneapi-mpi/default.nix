{ lib, pkg, cc, ... }:
with lib;
with lib.strings;
let
  # TODO
  # isGCC = compiler == "gcc";
  # isIntel = compiler == "intel";
  # cc = ""
  #   + optionalString isGCC "gcc"
  #   + optionalString isIntel "icc";
  # cxx = ""
  #   + optionalString isGCC "g++"
  #   + optionalString isIntel "icpc";
in
{
  libName = "mpi";
  libPath = "lib/release";

  # dependencies = [ ]
  #   ++ optional isGCC "gcc/${builtins.toString compilerVer}";

  # extraEnvVariables = builtins.toJSON {
  #   I_MPI_CC = "${cc}";
  #   I_MPI_CXX = "${cxx}";
  # };

  customScriptPath = "${pkg}/env/vars.sh";
}

