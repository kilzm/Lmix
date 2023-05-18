{ stdenv, lib, oneapi }:

stdenv.mkDerivation rec {
  pname = "intel-oneapi-llvm-compilers";
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

    for c in $compilers;
    do
      ln -s $compdir/linux/bin/$c $out/bin/$c
    done
  '';

  meta = {
    description = "Intel OneAPI C/C++ and Fortran Compilers";
    platforms = lib.platforms.linux;
    license = lib.licenses.unfree;
  };
}
