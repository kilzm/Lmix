{
  makeImpiCompatible = pkg:
    pkg.overrideAttrs (oldAttrs: {
      preConfigure = (oldAttrs.preConfigure or "") + ''
        export I_MPI_CC=$CC
        export I_MPI_CXX=$CXX
      '';
    });

  makeImpiCompatibleSetLD = pkg: mpi:
    pkg.overrideAttrs (oldAttrs: {
      preConfigure = (oldAttrs.preConfigure or "") + ''
        export I_MPI_CC=$CC
        export I_MPI_CXX=$CXX
        export NIX_LDFLAGS="$NIX_LDFLAGS -L${mpi}/lib/release"
      '';
    });
}