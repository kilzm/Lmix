
{ stdenv, lib, oneapi, version, makeWrapper }:

with lib.strings;
stdenv.mkDerivation rec {
  pname = "intel-oneapi-mpi";
  inherit version;

  phases = [ "installPhase" ];

  nativeBuildInputs = [ makeWrapper ];

  propagatedBuildInputs = [ oneapi ];

  mpidir = "${oneapi}/mpi/${version}";

  isGCC = "${stdenv.cc.pname}" == "gcc-wrapper";
  isIntel = "${stdenv.cc.pname}" == "oneapi-intel-compilers-wrapper";

  cc = ""
    + optionalString isGCC "gcc"
    + optionalString isIntel "icc";

  cxx = ""
    + optionalString isGCC "g++"
    + optionalString isIntel "icpc";

  installPhase = ''
    mkdir -p $out
    for dir in $mpidir/*; do
      name=$(basename $dir)
      ln -s $dir $out/$name
    done
  '';

  meta = {
    description = "Intel OneAPI Thread Building Blocks";
    platforms = lib.platforms.linux;
    license = lib.licenses.unfree;
  };
}
