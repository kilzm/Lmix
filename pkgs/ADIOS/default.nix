{ stdenv
, lib
, fetchFromGitHub
, cmake
, pkg-config
, fortran
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
, zfp
, zstd
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
    "-DADIOS2_USE_DataSpaces=OFF"
    "-DADIOS2_USE_IME=OFF"
    "-DCMAKE_DISABLE_FIND_PACKAGE_CrayDRC=TRUE"
    "-DCMAKE_DISABLE_FIND_PACKAGE_DAOS=TRUE"
  ];

  buildInputs = [
    hdf5.mpi
    bzip2
    libfabric
    rdma-core
    doxygen
    graphviz
    bison
    flex
    perl
    ucx
    zeromq
    hdf5
    libffi
    libsodium
    libpng
    c-blosc
    mgard
    protobuf
    sz
    zfp
    zstd
    python311
    python311Packages.numpy
    python311Packages.mpi4py
  ];

  nativeBuildInputs = [ cmake pkg-config fortran ];

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