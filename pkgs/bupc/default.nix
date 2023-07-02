{ stdenv
, lib
, fetchurl
, perl
, coreutils
, mpi
, procps
}:

stdenv.mkDerivation rec {
  pname = "bupc";
  version = "2022.10.0";

  src = fetchurl {
    url = "https://upc.lbl.gov/download/release/berkeley_upc-${version}.tar.gz";
    sha256 = "sha256-ZckvdxDixr06BTzJ0ErEdtmR4G05llIUsVgLEUR65LU=";
  };

  postPatch = ''
    patchShebangs .
  '';

  preConfigure = ''
    export I_MPI_CC=$CC
    export I_MPI_CXX=$CXX
    export MPICH_CC=$CC
    export MPICH_CXX=$CXX

    # configure checks for mpi runtime environment
    export I_MPI_ROOT=${mpi}
    if [[ -f "${mpi}/env/vars.sh" ]]; then
      source "${mpi}/env/vars.sh"
    fi
  '';

  ENVCMD = "${coreutils}/bin/env";

  buildInputs = [ perl mpi procps ];

  meta = with lib; {
    description = "A compiler for the Berkeley Unified Parallel C language";
    homepage = "https://upc/lbl.gov";
    license = licenses.bsd3;
    platforms = platforms.unix;
  };
}