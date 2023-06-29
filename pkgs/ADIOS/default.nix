{ stdenv
, lib
, fetchFromGitHub
, cmake
, pkg-config
, mpi
, hdf5
, bzip2
, zfp
, libfabric
, perl
, zeromq
, ucx
, c-blosc
, szip
, python311
, python311Packages
}:

with lib;
stdenv.mkDerivation rec {
  pname = "adios";
  version = "2.9.0";

  src = fetchFromGitHub {
    owner = "ornladios";
    repo = "ADIOS2";
    rev = "v${version}";
    sha256 = "sha256-CRpmhXYa3WSaeNOc//4A6dcQrUIyWpogUggkqng0JYA=";
  };

  cmakeFlags = [
    "-DPYTHON_EXECUTABLE=${python311}/bin/python3"
    "-DADIOS2_INSTALL_GENERATE_CONFIG=OFF"
  ];

  buildInputs = [
    hdf5.mpi
    hdf5
    bzip2
    perl
    python311
    libfabric
    zfp
    ucx
    zeromq
    c-blosc
    szip
    python311Packages.numpy
    python311Packages.mpi4py
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  passthru = {
    mpi = hdf5.mpi;
  };

  meta = with lib; {
    description = "The adapatable Input Output (I/O) System version 2";
    homepage = "https://csmd.ornl.gov/software/adios2";
    license = licenses.asl20;
    platform = platforms.unix;
  };
}