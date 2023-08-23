{ pkg, ... }:
{
  pkgName = "fftw";
  libName = "fftw3";

  extraPkgVariables = builtins.toJSON {
    WWW = "https://doku.lrz.de/display/PUBLIC/FFTW+-+Fastest+Fourier+Transform+in+the+West";
    OPENMP_SHLIB = "-L${pkg}/lib -lfftw_omp";
    PTHREADS_SHLIB = "-L${pkg}/lib -lfftw_pthreads";
    MPI_SHLIB = "-L${pkg}/lib -lfftw_mpi";
  };
}
