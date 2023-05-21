final: prev:
let
  getPkg = name:
    if builtins.hasAttr name prev.nwm-pkgs
      then prev.nwm-pkgs.${name}
      else prev.${name};

  defaultModules = attrNames:
    map
      (attrName: prev.callPackage ../modules {
        pkg = getPkg attrName;
        inherit attrName;
      })
      attrNames;

  namedModules = name: attrNames:
    map
      (attrName: prev.callPackage ../modules/${name} {
        pkg = getPkg attrName;
        inherit attrName;
      })
      attrNames;

  namedCCModules = name: compiler: compilerVer: attrNames:
    map
      (attrName: prev.callPackage ../modules/${name} {
        pkg = getPkg attrName;
        inherit attrName compiler compilerVer;
      })
      attrNames;
in
{
  nwm-mods = {
    # modules
    _modules-nixpkgs = prev.buildEnv {
      name = "modules-nixpkgs";
      paths = defaultModules [
        "nix-stdenv"
        "samtools"
        "ffmpeg"
        "git"
        "valgrind"
        "llvm"
      ]
      ++ namedModules "gcc" [
        "gcc7"
        "gcc8"
        "gcc9"
        "gcc10"
        "gcc11"
        "gcc12"
      ]
      ++ namedModules "ruby" [
        "ruby"
      ]
      ++ namedModules "python" [
        "python2"
        "python37"
        "python39"
        "python311"
      ];
    };

    _modules = prev.buildEnv {
      name = "modules";
      paths = defaultModules [
        "julia_1_9_0"
        "julia_1_8_5"
        "osu-micro-benchmarks_5_6_2"
        "osu-micro-benchmarks_6_1"
      ]
      ++ namedCCModules "openmpi" "gcc" 11 [
        "openmpi_4_1_4_gcc11"
        "openmpi_4_1_5_gcc11"
      ]
      ++ namedCCModules "fftw" "gcc" 11 [
        "fftw_3_3_10_gcc11_ompi_4_1_5"
      ]
      ++ namedCCModules "fftw" "gcc" 12 [
        "fftw_3_3_10_gcc12_ompi_4_1_5_openmp"
      ];
    };

    _modules-intel = prev.buildEnv {
      name = "modules-intel";
      paths = namedModules "intel/oneapi-compilers" [
        "intel-compilers_2022_1_0"
      ]
      ++ namedModules "intel/oneapi-tbb" [
        "intel-tbb_2021_6_0"
      ]
      ++ namedCCModules "intel/oneapi-mpi" "gcc" 12 [
        "intel-oneapi-mpi_2021_6_0_gcc11"
      ]
      ++ namedCCModules "intel/oneapi-mpi" "intel" 21 [
        "intel-oneapi-mpi_2021_6_0_intel21"
      ]
      ++ namedCCModules "fftw" "intel" 21 [
        "fftw_3_3_10_intel21"
      ];
    };
  };
}
