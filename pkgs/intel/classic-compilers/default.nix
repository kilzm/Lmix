{ stdenv, lib, oneapi }:

stdenv.mkDerivation rec {
  pname = "intel-classic-compilers";
  version = "2021.6.0";

  phases = [ "installPhase" ];

  propagatedBuildInputs = [ oneapi ];

  compdir = "${oneapi}/compiler/2022.1.0";

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/man
    compilers=$(find $compdir/linux/bin/intel64 -type f -executable -exec basename {} \;)
    echo $compilers
    for c in $compilers;
    do
      ln -s $compdir/linux/bin/intel64/$c $out/bin/$c
    done
    ln -s $compdir/linux/doc $out/share
    ln -s $compdir/documentation/en/man/common/man1 $out/share/man
  '';

  meta = {
    description = "Intel classic C/C++ and Fortran Compilers";
    platforms = lib.platforms.linux;
    license = lib.licenses.unfree;
  };
}
