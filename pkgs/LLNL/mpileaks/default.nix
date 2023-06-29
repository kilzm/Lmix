{ stdenv
, lib
, fetchFromGitHub
, autoreconfHook
, adept-utils
, callpath
# , mpi
}:

stdenv.mkDerivation rec {
  name = "mpileaks";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "LLNL";
    repo = "mpileaks";
    rev = "v${version}";
    sha256 = "sha256-AXkrTHeNE3HpYwUKsPQy42RoUW7cPvPGV+JKbUD/lZ4=";
  };

  preConfigure = ''
    export I_MPI_CC=$CC
    export MPICH_CC=$CC
  '';

  CXXFLAGS = "-std=c++11";

  configureFlags = [
    "--with-adept-utils=${adept-utils}"
    "--with-callpath=${callpath}"
  ];

  buildInputs = [
    adept-utils
    callpath
    callpath.mpi
  ];

  nativeBuildInputs = [
    autoreconfHook
  ];

  passthru = {
    mpi = callpath.mpi;
  };

  meta = with lib; {
    description = "Tool to detect and report MPI objects like MPI_Requests and MPI_Datatypes";
    license = licenses.bsd3;
    platforms = platforms.unix;
  };
}