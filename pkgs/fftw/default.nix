{ stdenv
, lib
, fetchurl
, perl
, gfortran
, precision ? "double"
, mpi ? null
, withOpenMP ? false
, enableAvx ? stdenv.hostPlatform.avxSupport
, enableAvx2 ? stdenv.hostPlatform.avx2Support
, enableAvx412 ? stdenv.hostPlatform.avx512Support
, enableFma ? stdenv.hostPlatform.fmaSupport
}:

with lib;

assert lib.elem precision [ "single" "double" "long-double" "quad-precision" ];

stdenv.mkDerivation rec {
  inherit mpi withOpenMP;
  pname = "fftw";
  version = "3.3.10";

  src = fetchurl {
    url = "ftp://ftp.fftw.org/pub/fftw/fftw-${version}.tar.gz";
    sha256 = "sha256-VskyVJhSzdz6/as4ILAgDHdCZ1vpIXnlnmIVs0DiZGc=";
  };

  nativeBuildInputs = [ gfortran ];

  buildInputs = [ mpi ];

  configureFlags = [
    "--enable-shared"
    "--enable-threads"
  ]
  ++ optional (precision != "double") "--enable-${precision}"
  ++ optional (precision == "single") "--enable-sse"
  ++ optional (precision == "single" || precision == "double") "--enable-sse2"
  ++ optional withOpenMP "--with-openmp"
  ++ optional (mpi != null) "--enable-mpi"
  ++ optional enableAvx "--enable-avx"
  ++ optional enableAvx2 "--enable-avx2"
  ++ optional enableFma "--enable-fma";

  enableParallelBuilding = true;

  meta = {
    description = "Fastest Fourier Transform in the West library";
    homepage = "https://fftw.org";
    license = lib.licenses.gpl2Plus;
    platforms = platforms.unix;
  };
}
