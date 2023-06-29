{ stdenv
, lib
, fetchFromGitHub
, cmake
, pkg-config
, bzip2
, boost
, libfabric
, ucx
}:

with lib;
stdenv.mkDerivation rec {
  pname = "mercury";
  version = "2.3.0";

  src = fetchFromGitHub {
    owner = "mercury-hpc";
    repo = "mercury";
    rev = "v${version}";
    sha256 = "sha256-o1fgn43waYobWsnnOPeiyP7p90+Hozk64I2OeNB3ax0=";
    fetchSubmodules = true;
  };

  cmakeFlags = [
    "-DBUILD_SHARED_LIBS=ON"
    "-DMERCURY_USE_BOOST_PP=ON"
    "-DMERCURY_USE_SYSTEM_BOOST=ON"
    "-DBoost_INCLUDE_DIR=${boost}/include"
    "-DNA_USE_OFI=ON"
    "-DNA_USE_SM=ON"
    "-DNA_USE_UCX=ON"
  ];

  buildInputs = [
    bzip2
    boost
    libfabric
    ucx
  ];

  nativeBuildInputs = [ cmake pkg-config ];

  meta = {
    description = "C library for implementing RPC, optimized for HPC";
    homepage = "www.mcs.anl.gov/projects/mercury";
    license = licenses.bsd3;
    platform = platforms.unix;
  };
}

