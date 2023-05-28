{ pkg, ... }:
{
  libName = "mpi";
  customPacName = "MPI";

  extraPkgVariables = builtins.toJSON {
    CXX_SHLIB = "-L${pkg}/lib -lmpi_cxx";
    F90_SHLIB = "-L${pkg}/lib -lmpi_mpifh";
    WWW = "https://doku.lrz.de/display/PUBLIC/OpenMPI";
  };
}
