{ stdenv
, lib
, fetchFromGitHub
, cmake
, pkg-config
, zlib
}:

stdenv.mkDerivation rec {
  pname = "sz";
  version = "2.1.12.5";

  src = fetchFromGitHub {
    owner = "szcompressor";
    repo = "SZ";
    rev = "v${version}";
    sha256 = "sha256-ypvuPH1qiAjWaVVLvXlINsrEqZQyOrM0vhjUzve46vU=";
  };

  buildInputs = [ zlib ];

  nativeBuildInputs = [ cmake pkg-config ];

  meta = with lib; {
    description = "Error-bounded Lossy Data Comporessor (for floating-point/integer datasets)";
    homepage = "szcompressor.org";
    license = licenses.bsd3;
    platform = platforms.unix;
  };
}