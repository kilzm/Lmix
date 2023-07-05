{ stdenv
, lib
, fetchFromGitHub
, cmake
, hdf5
, fortranSupport ? false
, fortran
}:

with lib;
stdenv.mkDerivation rec {
  pname = "cgns";
  version = "4.4.0";

  src = fetchFromGitHub {
    owner = "CGNS";
    repo = "CGNS";
    rev = "v${version}";
    sha256 = "sha256-giDosTfeZdkSIrzZrNrHgQBqlvDSABYPPHzSa/B9Rr0=";
  };

  buildInputs = [ hdf5 ]
    ++ optional hdf5.mpiSupport hdf5.mpi
    ++ optional hdf5.zlibSupport hdf5.zlib
    ++ optional hdf5.szipSupport hdf5.szip;

  nativeBuildInputs = [ cmake ] ++ optional fortranSupport fortran;

  preConfigure = strings.optionalString hdf5.mpiSupport ''
    export I_MPI_CC=$CC
    export I_MPI_ROOT=${hdf5.mpi}
  '';

  cmakeFlags = [ 
    "-DFORTRAN_NAMING=LOWERCASE_"
  ] ++ optional fortranSupport "-DCGNS_ENABLE_FORTRAN=ON"
    ++ optional hdf5.mpiSupport "-DHDF5_NEED_MPI=ON"
    ++ optional hdf5.zlibSupport "-DHDF5_NEED_ZLIB=ON"
    ++ optional hdf5.szipSupport "-DHDF5_NEED_SZIP=ON";

  passthru = {
    mpi = hdf5.mpi;
  };

  meta = {
    description = "CFD General Notation System";
    homepage = "https://cgns.github.io";
    license = licenses.zlib;
    platform = platforms.unix;
  };
}