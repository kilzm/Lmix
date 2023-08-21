{ stdenv
, lib
, fetchFromGitHub
, cmake
, mpi
, adept-utils
}:

stdenv.mkDerivation rec {
  pname = "callpath";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "LLNL";
    repo = "callpath";
    rev = "v${version}";
    sha256 = "sha256-xgBZIFk0yy3pEAHol9CSaYFwXjVrNU3r0JmfEsH172Y=";
  };

  buildInputs = [ mpi adept-utils ];

  nativeBuildInputs = [ cmake ];

  passthru = {
    inherit mpi;
  };

  meta = with lib; {
    description = "A tool for representing callpath information consistently in distributed-memory parallel applications";
    platforms = platforms.unix;
  };
}