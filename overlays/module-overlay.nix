final: prev:
let
  modulesFunc = recSet: name: mods:
    let
      inherit (prev.lib.attrsets) optionalAttrs;
      inherit (prev.lib.strings) optionalString;
      inherit (builtins) removeAttrs;
      callModule = m:
        let
          attrName = m.mod;
          pkg = if recSet == null then prev.${attrName} else prev.${recSet}.${attrName};
          configAttrs = optionalAttrs (name != null)
            (import ../modules/${name} {
              lib = prev.lib;
              inherit pkg;
              cc = m.cc or "";
            });
          extraAttrs = removeAttrs m [ "mod" ];
          modAttrs = {
            attrName = optionalString (recSet != null) "${recSet}." + attrName;
            inherit pkg;
          } // extraAttrs // configAttrs;
        in
        prev.callPackage ../modules modAttrs;
    in
    map callModule mods;

  defaultModulesNixpkgs = modulesFunc null null;
  defaultModules = modulesFunc "lmix-pkgs" null;
  namedModulesNixpkgs = modulesFunc null;
  namedModules = modulesFunc "lmix-pkgs";
in
{

  lmix-mods = {
    # modules
    _modules-nixpkgs = prev.buildEnv {
      name = "modules-nixpkgs";
      paths = defaultModulesNixpkgs [
        { mod = "ffmpeg"; }
        { mod = "git"; }
        { mod = "cmake"; }
        { mod = "valgrind"; incPath = "include/valgrind"; }
        { mod = "llvm"; libName = "LLVM"; }
        { mod = "eigen"; incPath = "include/eigen3"; }
        { mod = "libmatheval"; libName = "matheval"; }
        { mod = "libxc"; libName = "xc"; }
        # { mod = "libint"; libName = "int2"; }
        { mod = "pkgconfig"; pkgName = "pkgconfig"; }
        { mod = "autoconf"; }
        { mod = "autoconf-archive"; }
        { mod = "automake"; }
        { mod = "libtool"; }
        { mod = "blas"; }
        { mod = "openblas"; }
        { mod = "lapack"; }
        { mod = "mkl"; version = "2023.1.0"; pkgName = "intel-oneapi-mkl"; }
        { mod = "gsl"; }
        { mod = "gfortran7"; pkgName = "gfortran"; }
        { mod = "gfortran8"; pkgName = "gfortran"; }
        { mod = "gfortran9"; pkgName = "gfortran"; }
        { mod = "gfortran10"; pkgName = "gfortran"; }
        { mod = "gfortran11"; pkgName = "gfortran"; }
        { mod = "gfortran12"; pkgName = "gfortran"; }
      ]
      ++ namedModulesNixpkgs "gcc" [
        { mod = "gcc7"; }
        { mod = "gcc8"; }
        { mod = "gcc9"; }
        { mod = "gcc10"; }
        { mod = "gcc11"; }
        { mod = "gcc12"; }
      ]
      ++ namedModulesNixpkgs "ruby" [
        { mod = "ruby"; }
      ]
      ++ namedModulesNixpkgs "python" [
        { mod = "python2"; }
        { mod = "python38"; }
        { mod = "python39"; }
        { mod = "python311"; }
      ];
    };

    _modules = prev.buildEnv {
      name = "modules";
      paths = defaultModules [
        { mod = "nix-stdenv"; }
        { mod = "hello_2_12_1_intel21"; cc = "intel21"; }
        { mod = "hello_2_12_1_intel23"; cc = "intel23"; }
        { mod = "julia_1_9_0"; }
        { mod = "julia_1_8_5"; }
        { mod = "osu-micro-benchmarks_5_6_2"; }
        { mod = "osu-micro-benchmarks_6_1"; }
        { mod = "intel-oneapi-compilers_2023_1_0"; pkgName = "intel-oneapi-compilers"; }
        { mod = "intel-oneapi-classic-compilers_2021_9_0"; pkgName = "intel-oneapi-compilers"; version = "2021.9.0"; }
        { mod = "intel-oneapi-ifort_2021_9_0"; pkgName = "intel-oneapi-ifort"; }
        { mod = "intel-oneapi-tbb_2021_9_0"; libName = "tbb"; }   
      ]
      ++ namedModules "intel/oneapi-mpi" [
        { mod = "intel-mpi_2019"; pkgName = "intel-mpi"; cc = "intel21"; }
        { mod = "intel-oneapi-mpi_2021_9_0"; cc = "intel21"; }
      ]
      ++ namedModules "openmpi" [
        { mod = "openmpi_4_1_4_gcc11"; cc = "gcc11"; }
        { mod = "openmpi_4_1_5_gcc11"; cc = "gcc11"; }
      ]
      ++ namedModules "fftw" [
        { mod = "fftw_3_3_10_gcc11_ompi_4_1_5"; cc = "gcc11"; }
        { mod = "fftw_3_3_10_gcc12_ompi_4_1_5_openmp"; cc = "gcc12"; }
        { mod = "fftw_3_3_10_intel21"; cc = "intel21"; }
        { mod = "fftw_3_3_10_intel21_impi_2019"; cc = "intel21"; }
      ];
    };

    lmod2flake = prev.callPackage ../lmod2flake { };
  };
}
