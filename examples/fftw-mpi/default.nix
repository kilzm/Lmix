{ stdenv
, pkgconfig
, autoreconfHook
, automake
, autoconf-archive
, fftw
, mpi
}:

stdenv.mkDerivation {
  pname = "fftw_mpi";
  version = "1.0";
  src = ./.;

  buildInputs = [ fftw mpi ];

  nativeBuildInputs = [
    pkgconfig
    autoreconfHook
    automake
    autoconf-archive
  ];
}
