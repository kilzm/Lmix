{ stdenv, lib, oneapi, version, tbb }:

stdenv.mkDerivation rec {
  pname = "intel-oneapi-compilers";
  inherit version;

  phases = [ "installPhase" ];

  buildInputs = [ tbb ];

  propagatedBuildInputs = [ oneapi ];

  compdir = "${oneapi}/compiler/${version}";

  installPhase = ''
    mkdir -p $out
    for dir in $compdir/*; do
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
