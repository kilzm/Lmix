{ autoPatchelfHook, fetchurl, lib, stdenv }:

stdenv.mkDerivation rec { 
  pname = "julia-bin";
  version = "1.9.0-rc2";

  src = fetchurl {
    url = "https://julialang-s3.julialang.org/bin/linux/x64/${lib.versions.majorMinor version}/julia-${version}-linux-x86_64.tar.gz";
    sha256 = "sha256-Zk87UMFsCJ6eWAlYEHtKjo0a+CBiQpk2Abs0R7TTVBw=";
  };

  nativeBuildInputs = lib.optionals stdenv.isLinux [ autoPatchelfHook ];

  installPhase = ''
    runHook preInstall
    cp -r . $out
    runHook postInstall
  '';

  dontStrip = true;
}
