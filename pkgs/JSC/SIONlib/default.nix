{ stdenv
, lib
, fetchurl
, mpi
, fortran
, python ? null
, enablePython ? false
, cuda ? null
, enableCuda ? false
, sionfwd ? null
, enableSionfwd ? false
, disableMpi ? false
, disableOmp ? false
, disableOmpi ? false
, enableDebug ? false
, cctype
, mpitype
}:

assert enablePython -> (python != null);
assert lib.elem cctype ["gnu" "intel"];
assert lib.elem mpitype ["openmpi" "intel" "intel2" ];

with lib;
stdenv.mkDerivation rec {
  pname = "sionlib";
  version = "1.7.7";

  src = fetchurl {
    url = "https://apps.fz-juelich.de/jsc/sionlib/download.php?file=sionlib-1.7.7.tar.gz";
    sha256 = "sha256-pzV0scF8AwsdJWxfDqxf9ZY5X4uCfXWa+DRzv5T3RHc=";
  };

  configureFlags = [
    "--compiler=${cctype}"
    "--mpi=${mpitype}"
  ]
    ++ optional enablePython "--enable-python=3"
    ++ optional disableMpi "--disable-mpi"
    ++ optional disableOmp "--disable-omp"
    ++ optional disableOmpi "--disable-ompi"
    ++ optional enableDebug "--enable-debug"
    ++ optional enableSionfwd "--enable-sionfwd=${sionfwd}"
    ++ optional enableCuda "--enable-cuda=${cuda}";

  buildInputs = [
    mpi
    fortran
  ]
  ++ optional enablePython python
  ++ optional enableCuda cuda
  ++ optional enableSionfwd sionfwd;

  passthru = {
    inherit mpi;
  };

  meta = with lib; {
    description = "Scalable I/O library for parallel access to task-local files";
    license = licenses.bsd3;
    platforms = platforms.unix;
  };
}