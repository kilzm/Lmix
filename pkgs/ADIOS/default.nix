{ stdenv
, lib
, fetchFromGitHub
, cmake
, pkg-config
, fortran
, mpi
, bzip2
, libfabric
, rdma-core
, doxygen
, graphviz
, bison
, flex
, perl
, ucx
, zeromq
, hdf5
, libffi
, libsodium
, libpng
, c-blosc
, mgard
, protobuf
, sz
, python311
, python311Packages
, zfp
, zstd
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

  preConfigure = ''
    export FC=$FC_FOR_TARGET
  '';

  cmakeFlags = [
    "-DPYTHON_EXECUTABLE=${python311}/bin/python3"
    "-DADIOS2_INSTALL_GENERATE_CONFIG=OFF"
    "-DADIOS2_USE_DataSpaces=OFF"
    "-DADIOS2_USE_IME=OFF"
    "-DCMAKE_DISABLE_FIND_PACKAGE_CrayDRC=TRUE"
  ];

  buildInputs = [
    fortran
    rdma-core
    doxygen
    graphviz
    bison
    flex
    hdf5.mpi
    hdf5
    mgard
    zstd
    protobuf
    bzip2
    perl
    libfabric
    zfp
    ucx
    libsodium
    libpng
    libffi
    zeromq
    sz
    c-blosc
    python311
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