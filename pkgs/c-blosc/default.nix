{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "c-blosc";
  version = "2.9.3";

  src = fetchFromGitHub {
    owner = "Blosc";
    repo = "c-blosc2";
    rev = "v${version}";
    sha256 = "sha256-XGPTpf7YhPzPTxIdoPbQnITnJ1h5C7AJIzd/6kEqOT0=";
  };

  cmakeFlags = [
    "-DCMAKE_INSTALL_INCLUDEDIR=include"
    "-DCMAKE_INSTALL_LIBDIR=lib"
  ];

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    description = "A blocking, shuffling and loss-less compression library";
    homepage = "https:/www.blosc.org";
    license = licenses.bsd3;
    platforms = platforms.all;
  };
}