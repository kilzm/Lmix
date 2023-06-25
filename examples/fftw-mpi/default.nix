{ stdenv
, pkgconfig
, autoreconfHook
, autoconf-archive
, fftw
, mpi
}:

stdenv.mkDerivation {
  pname = "fftw_mpi";
  version = "1.0";
  src = ./.;

  # support intel-mpi mpicc
  preConfigure = ''
    export MPICH_CC=$CC
    export I_MPI_CC=$CC
  '';
  
  buildInputs = [ fftw mpi ];

  nativeBuildInputs = [
    pkgconfig
    autoreconfHook
    autoconf-archive
  ];
}
