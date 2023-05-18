{ stdenv, lib, oneapi, gcc, makeBinaryWrapper }:

stdenv.mkDerivation rec {
  pname = "intel-classic-compilers";
  version = "2021.6.0";

  phases = [ "installPhase" ];

  nativeBuildInputs = [ makeBinaryWrapper ];

  propagatedBuildInputs = [ oneapi gcc ];

  compdir = "${oneapi}/compiler/2022.1.0";

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/nix-support
    ln -s $compdir/linux/bin/intel64/* $out/bin

    for c in ifort xiar xild; do
      wrapProgramBinary $out/bin/$c --add-flags "-gcc-name=${gcc}/bin/gcc"
    done
    
    # the patched cc-wrapper reads this file and adds the specified flags
    # these flags are necessary because intel compilers expect gcc to be in /usr/bin/gcc
    echo "-gcc-name=${gcc}/bin/gcc" >> $out/nix-support/extra-cflags
    echo "-gxx-name=${gcc}/bin/g++" >> $out/nix-support/extra-cflags
  '';

  meta = {
    description = "Intel classic C/C++ and Fortran Compilers";
    platforms = lib.platforms.linux;
    license = lib.licenses.unfree;
  };
}
