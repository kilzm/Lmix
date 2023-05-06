final: prev:
with prev.lib; rec {
  ## hello - mirror://gnu/hello/hello-${version}.tar.gz
  hello = prev.hello;

  hello_2_12_1 = hello.overrideAttrs (old: rec {
    version = "2.12.1";
    src = prev.fetchurl {
      url = "mirror://gnu/hello/hello-${version}.tar.gz";
      sha256 = "sha256-jZkUKv2SV28wsM18tCqNxoCZmLxdYH2Idh9RLibH2yA=";
    };
  });

  hello_2_9 = hello.overrideAttrs (old: rec {
    version = "2.9";
    src = prev.fetchurl {
      url = "mirror://gnu/hello/hello-${version}.tar.gz";
      sha256 = "sha256-7Lt6IhQZbFf/k0CqcUWOFVmr049tjRaWZoRpNd8ZHqc=";
    };
  });

  ## julia - https://github.com/JuliaLang/julia/releases/download/v${version}/julia-${version}-full.tar.gz
  julia = prev.julia_18;

  julia_1_8_5 = prev.julia_18;

  julia_1_9_0 = prev.callPackage ./pkgs/julia/1.9.0-rc2-bin.nix { };

  ## openmpi - https://www.open-mpi.org/software/ompi/v${major version}.${minor version}/downloads/openmpi-${version}.tar.bz2
  openmpi = prev.openmpi;

  openmpi_4_1_5 = openmpi.overrideAttrs (old: rec {
    version = "4.1.5";

    src = prev.fetchurl {
      url = "https://www.open-mpi.org/software/ompi/v${versions.major version}.${versions.minor version}/downloads/openmpi-${version}.tar.bz2";
      sha256 = "sha256-pkCYa8JXOJ3TeYhv2uYmTIz6VryYtxzjrj372M5h2+M=";
    };
  });

  ## osu-micro-benchmarks - mvapich.cse.ohio-state.edu/download/mvapich/osu-micro-benchmarks-${version}.tar.gz
  osu-micro-benchmarks = prev.callPackage ./pkgs/osu-micro-benchmarks {
    mpi = openmpi_4_1_5;
  };

  osu-micro-benchmarks_5_6_2 = osu-micro-benchmarks;

  osu-micro-benchmarks_5_4 = osu-micro-benchmarks.overrideAttrs (old: rec {
    version = "5.4";
    src = prev.fetchurl {
      url = "mvapich.cse.ohio-state.edu/download/mvapich/osu-micro-benchmarks-${version}.tar.gz";
      sha256 = "sha256-4cp2LhOgcgWlm1mthehc4Pgmtw92/VVc5VaO+x8qjzM=";
    };
  });

  osu-micro-benchmarks_6_1 = osu-micro-benchmarks.overrideAttrs (old: rec {
    version = "6.1";
    src = prev.fetchurl {
      url = "mvapich.cse.ohio-state.edu/download/mvapich/osu-micro-benchmarks-${version}.tar.gz";
      sha256 = "sha256-7MztyGgmT3XbTZUpr3kAVBmid1ETx/ro9OSoQ0Ni5Kc=";
    };
  });

  ## fftw - ftp://ftp.fftw.org/pub/fftw/fftw-${version}.tar.gz
  fftw = prev.callPackage ./pkgs/fftw {
    mpi = openmpi_4_1_5;  
  };

  fftw_3_3_10_ompi_4_1_5 = prev.callPackage ./pkgs/fftw {
    mpi = openmpi_4_1_5;
  };

  fftw_3_3_10_ompi_4_1_5_openmp = prev.callPackage ./pkgs/fftw {
    mpi = openmpi_4_1_5;
    withOpenMP = true;
  };

  # intel
  intel-oneapi_2022_2_0 = prev.callPackage ./pkgs/intel/oneapi { };

  intel-compilers_2022_1_0 = prev.callPackage ./pkgs/intel/compilers {
    oneapi = intel-oneapi_2022_2_0;
  };

  intel-classic-compilers_2021_6_0 = prev.callPackage ./pkgs/intel/classic-compilers {
    oneapi = intel-oneapi_2022_2_0;
  };

  # modules
  modules = prev.buildEnv {
    name = "modules";
    paths = map
      (pkg: prev.callPackage ./modules {
        inherit pkg;
      })
      (with final; [
        julia_1_9_0
        julia_1_8_5
        openmpi_4_1_5
        osu-micro-benchmarks_5_6_2
        osu-micro-benchmarks_6_1
        fftw_3_3_10_ompi_4_1_5_openmp
      ]);
  };

  modules-intel = prev.buildEnv {
    name = "modules-intel";
    paths = map
      (pkg: prev.callPackage ./modules {
        inherit pkg;
      })
      (with final; [
        intel-compilers_2022_1_0
        intel-classic-compilers_2021_6_0
      ]);
  };
}
