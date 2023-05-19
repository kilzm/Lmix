{ stdenv, lib, oneapi, version }:

stdenv.mkDerivation rec {
  pname = "intel-oneapi-tbb";
  inherit version;

  phases = [ "installPhase" ];

  propagatedBuildInputs = [ oneapi ];

  tbbdir = "${oneapi}/tbb/${version}";

  installPhase = ''
    mkdir -p $out
    for dir in $tbbdir/*; do
      name=$(basename $dir)
      ln -s $dir $out/$name
    done
  '';

  meta = {
    description = "Intel OneAPI C/C++ and Fortran Compilers";
    platforms = lib.platforms.linux;
    license = lib.licenses.unfree;
  };
}
