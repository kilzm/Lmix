{ stdenv
, lib
, fetchFromGitHub
, cmake
, pkg-config
, zlib
, zstd
, python3
, protobuf
}:

stdenv.mkDerivation rec {
  pname = "mgard";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "CODARcode";
    repo = "MGARD";
    rev = "${version}";
    sha256 = "sha256-mLlU/l3SQ9kUyxXVVxz5hyDSwJKfJBxxELA6Zg67ZJY=";
  };

  cmakeFlags = [
    "-DMGARD_ENABLE_OPENMP=ON"
    "-Dzstd_INCLUDE_DIR=${zstd}/include"
  ];

  buildInputs = [ zlib zstd python3 protobuf ];

  nativeBuildInputs = [ cmake pkg-config ];

  meta = with lib; {
    license = licenses.asl20;
  };
}