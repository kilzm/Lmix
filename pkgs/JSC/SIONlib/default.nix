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

with lib;
assert enablePython -> (python != null);
assert enableCuda -> (cuda != null);
assert enableSionfwd -> (sionfwd != null);
assert elem cctype ["gnu" "intel"];
assert elem mpitype ["openmpi" "intel" "intel2"];

stdenv.mkDerivation rec {
  pname = "sionlib";
  version = "1.7.7";

  src = fetchurl {
    url = "https://apps.fz-juelich.de/jsc/sionlib/download.php?file=sionlib-${version}.tar.gz";
    sha256 = "sha256-pzV0scF8AwsdJWxfDqxf9ZY5X4uCfXWa+DRzv5T3RHc=";
  };

  configureFlags = [
    "--compiler=${cctype}"
    "--mpi=${mpitype}"
  ]
    ++ optional enablePython "--enable-python=${versions.major python.version}"
    ++ optional disableMpi "--disable-mpi"
    ++ optional disableOmp "--disable-omp"
    ++ optional disableOmpi "--disable-ompi"
    ++ optional enableDebug "--enable-debug"
    ++ optional enableSionfwd "--enable-sionfwd=${sionfwd}"
    ++ optional enableCuda "--enable-cuda=${cuda}";

  buildInputs = [
    mpi
  ]
  ++ optional enablePython python
  ++ optional enableCuda cuda
  ++ optional enableSionfwd sionfwd;

  nativeBuildInputs = [ fortran ];

  passthru = {
    inherit mpi;
  };

  meta = with lib; {
    description = "Scalable I/O library for parallel access to task-local files";
    homepage = "https://www.fz-juelich.de/en/ias/jsc/services/user-support/jsc-software-tools/sionlib";
    license = licenses.bsd3;
    platforms = platforms.unix;
  };
}