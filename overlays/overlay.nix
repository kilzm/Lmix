final: prev:
let
  wrapICCWith =
    { cc
    , bintools ? prev.bintools
    , libc ? bintools.libc
    , ...
    } @extraArgs:
    prev.callPackage ../pkgs/intel/build-support/cc-wrapper (
      let
        self = {
          nativeTools = prev.targetPlatform == prev.hostPlatform && prev.stdenv.cc.nativeTools or false;
          nativeLibc = prev.targetPlatform == prev.hostPlatform && prev.stdenv.cc.nativeLibc or false;
          nativePrefix = prev.stdenv.cc.nativePrefix or "";
          noLibc = !self.nativeLibc && (self.libc == null);

          isGNU = false;
          isClang = false;
          isIntel = true;

          inherit cc bintools libc;
        } // extraArgs;
      in
      self
    );

in
{
  nwm-pkgs = with prev.lib; rec {
    ## hello - mirror://gnu/hello/hello-${version}.tar.gz
    hello = prev.hello;

    hello_2_12_1 = hello.overrideAttrs (old: rec {
      version = "2.12.1";
      src = prev.fetchurl {
        url = "mirror://gnu/hello/hello-${version}.tar.gz";
        sha256 = "sha256-jZkUKv2SV28wsM18tCqNxoCZmLxdYH2Idh9RLibH2yA=";
      };
    });

    hello_2_9_intel21 = (hello.override { stdenv = intel21Stdenv; }).overrideAttrs (old: rec {
      version = "2.9";
      src = prev.fetchurl {
        url = "mirror://gnu/hello/hello-${version}.tar.gz";
        sha256 = "sha256-7Lt6IhQZbFf/k0CqcUWOFVmr049tjRaWZoRpNd8ZHqc=";
      };
    });

    ## julia - https://github.com/JuliaLang/julia/releases/download/v${version}/julia-${version}-full.tar.gz
    julia = prev.julia_18;

    julia_1_8_5 = prev.julia_18;

    julia_1_9_0 = prev.callPackage ../pkgs/julia/1.9.0-rc2-bin.nix { };

    ## openmpi - https://www.open-mpi.org/software/ompi/v${major version}.${minor version}/downloads/openmpi-${version}.tar.bz2
    openmpi = prev.callPackage ../pkgs/openmpi/default.nix { };

    openmpi_4_1_4_gcc11 = prev.callPackage ../pkgs/openmpi/default.nix {
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
    osu-micro-benchmarks = prev.callPackage ../pkgs/osu-micro-benchmarks {
      mpi = openmpi_4_1_5_gcc11;
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
    # fftw = prev.callPackage ../pkgs/fftw {
    #   mpi = openmpi_4_1_5_gcc11;
    # };

    fftw_3_3_10_gcc11_ompi_4_1_5 = prev.callPackage ../pkgs/fftw {
      stdenv = prev.gcc11Stdenv;
      mpi = openmpi_4_1_5_gcc11;
    };

    fftw_3_3_10_gcc12_ompi_4_1_5_openmp = prev.callPackage ../pkgs/fftw {
      stdenv = prev.gcc12Stdenv;
      mpi = openmpi_4_1_5_gcc11;
      withOpenMP = true;
    };

    fftw_3_3_10_intel21 = prev.callPackage ../pkgs/fftw {
      stdenv = intel21Stdenv;
      mpi = null;
    };

    # intel

    # begin oneapi-2022.2.0
    intel-oneapi_2022_2_0 = prev.callPackage ../pkgs/intel/oneapi { };

    oneapi = intel-oneapi_2022_2_0;

    intel-tbb_2021_6_0 = prev.callPackage ../pkgs/intel/oneapi-tbb {
      oneapi = intel-oneapi_2022_2_0;
      version = "2021.6.0";
    };

    intel-compilers_2022_1_0 = prev.callPackage ../pkgs/intel/oneapi-compilers {
      oneapi = intel-oneapi_2022_2_0;
      tbb = intel-tbb_2021_6_0;
      version = "2022.1.0";
    };

    intel-classic-compilers_2021_6_0 = prev.callPackage ../pkgs/intel/oneapi-classic-compilers {
      oneapi = intel-oneapi_2022_2_0;
    };

    intel-oneapi-mpi_2021_6_0_gcc11 = prev.callPackage ../pkgs/intel/oneapi-mpi {
      oneapi = intel-oneapi_2022_2_0;
      version = "2021.6.0";
      stdenv = prev.gcc11Stdenv;
    };

    intel-oneapi-mpi_2021_6_0_intel21 = prev.callPackage ../pkgs/intel/oneapi-mpi {
      oneapi = intel-oneapi_2022_2_0;
      version = "2021.6.0";
      stdenv = intel21Stdenv;
    };

    intel21Stdenv =
      let
        intel21-wrapped = wrapICCWith rec {
          cc = prev.callPackage ../pkgs/intel/oneapi-classic-compilers {
            oneapi = intel-oneapi_2022_2_0;
          };
        };
      in
      prev.overrideCC prev.stdenv intel21-wrapped;
    # end oneapi-2022.2.0

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
