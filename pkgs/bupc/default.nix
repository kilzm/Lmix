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
    # configure checks for mpi runtime environment
    if [[ -f "${mpi}/env/vars.sh" ]]; then
      source "${mpi}/env/vars.sh"
    fi
  '';

  ENVCMD = "${coreutils}/bin/env";

  buildInputs = [ perl mpi procps ];

  passthru = { inherit mpi; };

  meta = with lib; {
    description = "A compiler for the Berkeley Unified Parallel C language";
    homepage = "https://upc/lbl.gov";
    license = licenses.bsd3;
    platforms = platforms.unix;
  };
}