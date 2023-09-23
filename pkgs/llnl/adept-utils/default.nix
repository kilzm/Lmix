{ stdenv
, lib
, fetchFromGitHub
, cmake
, boost
}:

stdenv.mkDerivation rec {
  pname = "adept-utils";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "LLNL";
    repo = "adept-utils";
    rev = "v${version}";
    sha256 = "sha256-j2K8UxrdgEXiYwCM6BsAxq0kV+K5IGjAlBjq0fFyUTY=";
  };

  buildInputs = [ boost ];

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    description = "Set of libraries for commonly useful routines for ADEPT code projects";
    license = licenses.bsd3;
    platforms = platforms.unix;
  };
}