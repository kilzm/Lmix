{ stdenv, lib, oneapi }:

stdenv.mkDerivation rec {
  pname = "intel-compilers";
  version = "2022.1.0";

  phases = [ "installPhase" ];

  propagatedBuildInputs = [ oneapi ];

  compdir = "${oneapi}/compiler/${version}";

  compilers = [
    "icx"
    "icpx"
    "ifx"
    "dpcpp"
    "dpcpp-cl"
  ];

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/man
    for c in $compilers;
    do
      ln -s $compdir/linux/bin/$c $out/bin/$c
    done
    ln -s $compdir/linux/doc $out/share
    ln -s $compdir/documentation/en/man/common/man1 $out/share/man
  '';

  meta = {
    description = "Intel OneAPI C/C++ and Fortran Compilers";
    platforms = lib.platforms.linux;
    license = lib.licenses.unfree;
  };
}
