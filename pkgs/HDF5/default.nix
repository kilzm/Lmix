{ lib
, stdenv
, fetchurl
, removeReferencesTo
, cmake
, perl
, cppSupport ? false
, fortranSupport ? false
, fortran ? null
, zlibSupport ? true
, zlib
, szipSupport ? true
, szip
, mpiSupport ? false
, mpi
, javaSupport ? false
, jdk
, usev110Api ? false
, threadsafe ? false
, python3
}:

assert !cppSupport || !mpiSupport;

let inherit (lib) optional optionals; in

with lib;
stdenv.mkDerivation rec {
  pname = "hdf5"
    + lib.optionalString cppSupport "-cpp"
    + lib.optionalString fortranSupport "-fortran"
    + lib.optionalString mpiSupport "-mpi"
    + lib.optionalString threadsafe "-threadsafe";
  version = "1.14.1";
  versionSuffix = "-2";
  majMin = versions.majorMinor version;
  fullVersion = "${version}${versionSuffix}";

  srcs = fetchurl {
    url = "https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-${majMin}/hdf5-${version}/src/hdf5-${fullVersion}.tar.gz";
    sha256 = "sha256-y+k/J11SMd8oztlUklN5PkDNK1VePSiN8J17iamWewc=";
  };

  passthru = {
    inherit
      cppSupport
      fortranSupport
      fortran
      zlibSupport
      zlib
      szipSupport
      szip
      mpiSupport
      mpi;
  };

  nativeBuildInputs = [ 
    removeReferencesTo 
    cmake
    perl
  ] ++ optional fortranSupport fortran;

  buildInputs = [
  ] ++ optional fortranSupport fortran
    ++ optional szipSupport szip
    ++ optional javaSupport jdk;

  propagatedBuildInputs = [
  ] ++ optional zlibSupport zlib
    ++ optional mpiSupport mpi;

  preConfigure = ''
    export I_MPI_CC=$CC
    export I_MPI_ROOT=${mpi}
  '';

  cmakeFlags = [ 
    "-DHDF5_USE_GNU_DIRS=TRUE"
    "-DCMAKE_INSTALL_INCLUDEDIR=include"
    "-DCMAKE_INSTALL_LIBDIR=lib"
  ] ++ optional cppSupport "-DHDF5_BUILD_CPP_LIB=ON"
    ++ optional fortranSupport "-DHDF5_BUILD_FORTRAN=ON"
    ++ optional (!zlibSupport) "-DHDF5_ENABLE_ZLIB=OFF"
    ++ optional szipSupport "-DHDF5_ENABLE_SZIP=ON"
    ++ optionals mpiSupport [ "-DHDF5_ENABLE_PARALLEL=ON" ]
    ++ optional javaSupport "-DHDF5_BUILD_JAVA"
    ++ optional usev110Api "-DDEFAULT_API_VERSION=v110"
    ++ optionals threadsafe [ "-DHDF5_ENABLE_THREADSAFE" "-DHDF5_BUILD_HL_LIB=OFF" ];

  postInstall = ''
    find "$out" -type f -exec remove-references-to -t ${stdenv.cc} '{}' +
  '';

  passthru.tests = {
    inherit (python3.pkgs) h5py;
  };

  meta = with lib; {
    description = "Data model, library, and file format for storing and managing data";
    longDescription = ''
      HDF5 supports an unlimited variety of datatypes, and is designed for flexible and efficient
      I/O and for high volume and complex data. HDF5 is portable and is extensible, allowing
      applications to evolve in their use of HDF5. The HDF5 Technology suite includes tools and
      applications for managing, manipulating, viewing, and analyzing data in the HDF5 format.
    '';
    homepage = "https://www.hdfgroup.org/HDF5/";
    license = licenses.bsd3; # Lawrence Berkeley National Labs BSD 3-Clause variant
    platforms = platforms.unix;
  };
}