final: prev:
with prev.lib;
let
  inherit (prev) callPackage;

  intel-oneapi_2023_1_0 = callPackage ../pkgs/intel/oneapi {
    libffi = prev.libffi_3_3;
    versions = import ../pkgs/intel/oneapi/2023.nix;
  };

  hdf5_impi_compatible = prev.hdf5.overrideAttrs (old: {
    preConfigure = "export I_MPI_CC=$CC";
  });
in
{
  lmix-pkgs = rec {
    # intel
    intel-oneapi-compilers_2023_1_0 = intel-oneapi_2023_1_0.icx;
    intel-oneapi-classic-compilers_2021_9_0 = intel-oneapi_2023_1_0.icc;
    intel-oneapi-ifort_2021_9_0 = intel-oneapi_2023_1_0.ifort;
    intel-oneapi-tbb_2021_9_0 = intel-oneapi_2023_1_0.tbb;
    intel-oneapi-mpi_2021_9_0 = intel-oneapi_2023_1_0.mpi;

    intel23Stdenv = intel-oneapi_2023_1_0.stdenv;
    intel21Stdenv = intel-oneapi_2023_1_0.stdenv-icc;

    intel-mpi_2019 = callPackage ../pkgs/intel/mpi { };

    ## hello - mirror://gnu/hello/hello-${version}.tar.gz
    hello_2_12_1 = prev.hello.overrideAttrs (old: rec {
      version = "2.12.1";
      src = prev.fetchurl {
        url = "mirror://gnu/hello/hello-${version}.tar.gz";
        sha256 = "sha256-jZkUKv2SV28wsM18tCqNxoCZmLxdYH2Idh9RLibH2yA=";
      };
    });

    hello_2_12_1_intel21 = hello_2_12_1.override {
      stdenv = intel21Stdenv;
    };

    hello_2_12_1_intel23 = (hello_2_12_1.override {
      stdenv = intel23Stdenv;
    }).overrideAttrs (old: {
      doCheck = false;
    });

    ## julia - https://github.com/JuliaLang/julia/releases/download/v${version}/julia-${version}-full.tar.gz
    julia_1_8_5 = prev.julia_18;

    julia_1_9_0 = callPackage ../pkgs/julia/1.9.0-rc2-bin.nix { };

    ## openmpi - https://www.open-mpi.org/software/ompi/v${major version}.${minor version}/downloads/openmpi-${version}.tar.bz2
    openmpi_4_1_4_gcc11 = callPackage ../pkgs/openmpi/default.nix {
      stdenv = prev.gcc11Stdenv;
    };

    openmpi_4_1_5_gcc11 = openmpi_4_1_4_gcc11.overrideAttrs (old: rec {
      version = "4.1.5";
      src = prev.fetchurl {
        url = "https://www.open-mpi.org/software/ompi/v${versions.major version}.${versions.minor version}/downloads/openmpi-${version}.tar.bz2";
        sha256 = "sha256-pkCYa8JXOJ3TeYhv2uYmTIz6VryYtxzjrj372M5h2+M=";
      };
    });

    ## osu-micro-benchmarks - mvapich.cse.ohio-state.edu/download/mvapich/osu-micro-benchmarks-${version}.tar.gz
    osu-micro-benchmarks = osu-micro-benchmarks_5_6_2;

    osu-micro-benchmarks_5_6_2 = callPackage ../pkgs/osu-micro-benchmarks {
      mpi = openmpi_4_1_5_gcc11;
    };

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
    fftw_3_3_10_gcc11_ompi_4_1_5 = callPackage ../pkgs/fftw {
      stdenv = prev.gcc11Stdenv;
      mpi = openmpi_4_1_5_gcc11;
    };

    fftw_3_3_10_gcc12_ompi_4_1_5_openmp = callPackage ../pkgs/fftw {
      stdenv = prev.gcc12Stdenv;
      mpi = openmpi_4_1_5_gcc11;
      withOpenMP = true;
    };

    fftw_3_3_10_intel21 = callPackage ../pkgs/fftw {
      stdenv = intel21Stdenv;
      mpi = null;
    };

    fftw_3_3_10_intel21_impi_2019 = callPackage ../pkgs/fftw {
      stdenv = intel21Stdenv;
      mpi = intel-mpi_2019;
    };

    # LLNL
    adept-utils_1_0_1 = callPackage ../pkgs/LLNL/adept-utils {
      stdenv = intel21Stdenv;
    };

    callpath_1_0_4_impi_2019 = callPackage ../pkgs/LLNL/callpath { 
      mpi = intel-mpi_2019;
      adept-utils = adept-utils_1_0_1;
    };

    mpileaks_1_0_impi_2019 = callPackage ../pkgs/LLNL/mpileaks {
      adept-utils = adept-utils_1_0_1;
      callpath = callpath_1_0_4_impi_2019;
      # mpi is inherited from callpath
    };

    # JSC
    sionlib_1_7_7_intel21_impi_2019 = callPackage ../pkgs/JSC/SIONlib {
      cctype = "intel";
      mpitype = "intel2";
      stdenv = intel21Stdenv;
      fortran = intel-oneapi-ifort_2021_9_0;
      mpi = intel-mpi_2019;
      enablePython = true;
      python = prev.python311;
    };

    hdf5_intel21_impi_2019 = hdf5_impi_compatible.override {
      stdenv = intel21Stdenv;
      mpiSupport = true;
      mpi = intel-mpi_2019;
    };

    c-blosc_2_9_3_intel21 = callPackage ../pkgs/c-blosc {
      stdenv = intel21Stdenv;
    };

    mercury_2_3_0_intel21 = callPackage ../pkgs/mercury {
      stdenv = intel21Stdenv;
    };

    sz_2_1_12_intel21 = callPackage ../pkgs/SZ {
      stdenv = intel21Stdenv;
    };

    mgard_1_5_0_intel23 = callPackage ../pkgs/MGARD {
      stdenv = intel23Stdenv; # intel21 fails
    };

    adios_2_9_0_intel21_impi_2019 = callPackage ../pkgs/ADIOS {
      stdenv = intel21Stdenv;
      fortran = intel-oneapi-ifort_2021_9_0;
      hdf5 = hdf5_intel21_impi_2019;
      c-blosc = c-blosc_2_9_3_intel21;
      sz = sz_2_1_12_intel21;
      mgard = mgard_1_5_0_intel23;
      # mpi is inherited from hdf5
    };

    # default environment when working with nix-generated modules
    nix-stdenv = prev.buildEnv {
      name = "nix-stdenv";
      paths = (with final; [
        gcc
        glibc
        coreutils
        binutils
        findutils
        diffutils
        gnused
        gnugrep
        gawk
        gnutar
        gzip
        bzip2
        gnumake
        bashInteractive
        patch
        xz
        file
      ]);
    };
  };
}
