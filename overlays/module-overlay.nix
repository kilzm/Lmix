final: prev:
with prev.lib;
let
  modulesFunc = recSet: name: mods:
    let
      callModule = m:
        let
          attrName = m.mod;
          pkg = if recSet == null then prev.${attrName} else prev.${recSet}.${attrName};
          configAttrs = attrsets.optionalAttrs (name != null)
            (import ../modules/${name} {
              lib = prev.lib;
              inherit pkg;
              cc = m.cc or "";
            });
          extraAttrs = builtins.removeAttrs m [ "mod" "nixHook" ];
          modAttrs = {
            attrName = strings.optionalString (recSet != null) "${recSet}." + (m.nixHook or attrName);
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
        { mod = "R"; }
        { mod = "ffmpeg"; }
        { mod = "git"; }
        { mod = "valgrind"; }
        { mod = "strace"; }
        { mod = "ltrace"; }
        { mod = "heaptrack"; }
        { mod = "llvm"; libName = "LLVM"; }
        { mod = "eigen"; incPath = "include/eigen3"; }
        { mod = "libmatheval"; libName = "matheval"; }
        { mod = "libxc"; libName = "xc"; }
        { mod = "openblas"; }
        { mod = "lapack-reference"; pkgName = "lapack"; }
        { mod = "mkl"; version = "2023.1.0"; pkgName = "intel-oneapi-mkl"; }
        { mod = "gsl"; }
        { mod = "boost"; }
        { mod = "libfabric"; libName = "fabric"; }
        { mod = "gfortran7"; pkgName = "gfortran"; native = true; }
        { mod = "gfortran8"; pkgName = "gfortran"; native = true; }
        { mod = "gfortran9"; pkgName = "gfortran"; native = true; }
        { mod = "gfortran10"; pkgName = "gfortran"; native = true; }
        { mod = "gfortran11"; pkgName = "gfortran"; native = true; }
        { mod = "gfortran12"; pkgName = "gfortran"; native = true; }
        { mod = "cmake"; native = true; }
        { mod = "pkgconfig"; pkgName = "pkgconfig"; native = true; }
        { mod = "autoconf"; nixHook = "autoreconfHook"; native = true; }
        { mod = "automake"; native = true; }
        { mod = "libtool"; native = true; }
        { mod = "autoconf-archive"; native = true; }
      ]
      ++ namedModulesNixpkgs "gcc" [
        { mod = "gcc7"; ccStdenv = "gcc7Stdenv"; }
        { mod = "gcc8"; ccStdenv = "gcc8Stdenv"; }
        { mod = "gcc9"; ccStdenv = "gcc9Stdenv"; }
        { mod = "gcc10"; ccStdenv = "gcc10Stdenv"; }
        { mod = "gcc11"; ccStdenv = "gcc11Stdenv"; }
        { mod = "gcc12"; ccStdenv = "gcc12Stdenv"; }
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
        { mod = "hdf5_intel21_impi_2019"; pkgName = "hdf5"; cc = "intel21"; }
        { mod = "hdf5_gcc12_impi_2021"; pkgName = "hdf5"; cc = "gcc12"; }
        { mod = "hdf5_gcc11_ompi_4_1_4"; pkgName = "hdf5"; cc = "gcc11"; }
        { mod = "mercury_2_3_0_intel21"; cc = "intel21"; }
        { mod = "c-blosc_2_9_3_intel21"; libName = "blosc2"; cc = "intel21"; }
        { mod = "sz_2_1_12_intel21"; libName = "SZ"; cc = "intel21"; }
        { mod = "mgard_1_5_0_intel23"; cc = "intel23"; }
        { mod = "adios_2_9_0_intel21_impi_2019"; libName = "adios2_core"; cc = "intel21"; }
        { mod = "adept-utils_1_0_1_gcc11"; cc = "gcc11"; }
        { mod = "callpath_1_0_4_gcc11_impi_2019"; cc = "gcc11"; }
        { mod = "mpileaks_1_0_gcc11_impi_2019"; cc = "gcc11"; }
        { mod = "sionlib_1_7_7_gcc10_impi_2019"; cc = "gcc10"; }
        { mod = "cgns_4_4_0_gcc12_impi_2021"; cc = "gcc12"; }
        { mod = "bupc_2022_10_0_intel23_impi_2021"; cc = "intel23"; }
        # intel
        { mod = "intel-oneapi-compilers_2023_1_0"; pkgName = "intel-oneapi-compilers"; ccStdenv = "lmix-pkgs.intel23Stdenv"; }
        { 
          mod = "intel-oneapi-classic-compilers_2021_9_0";  pkgName = "intel-oneapi-classic"; 
          version = "2021.9.0"; ccStdenv = "lmix-pkgs.intel21Stdenv"; 
        }
        { mod = "intel-oneapi-ifort_2021_9_0"; pkgName = "intel-oneapi-ifort"; native = true; }
        { mod = "intel-oneapi-tbb_2021_9_0"; libName = "tbb"; }   
      ]
      ++ namedModules "intel/oneapi-mpi" [
        { mod = "intel-oneapi-mpi_2021_9_0"; cc = "intel"; }
        { mod = "intel-oneapi-mpi_2021_9_0"; cc = "gcc"; }
      ]
      ++ namedModules "intel/mpi" [
        { mod = "intel-mpi_2019"; pkgName = "intel-mpi"; cc = "intel"; }
        { mod = "intel-mpi_2019"; pkgName = "intel-mpi"; cc = "gcc"; }
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
