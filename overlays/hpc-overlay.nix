final: prev:
with prev.lib;
let
  inherit (prev) callPackage;
  inherit (prev) gcc7Stdenv gcc8Stdenv gcc9Stdenv gcc10Stdenv gcc11Stdenv gcc12Stdenv;

  intel-oneapi_2023_1_0 = callPackage ../pkgs/intel/oneapi {
    libffi = prev.libffi_3_3;
    versions = import ../pkgs/intel/oneapi/2023.nix;
  };

in
{
  lmix-pkgs = rec {

    # intel
    intel-oneapi-compilers_2023_1_0 = intel-oneapi_2023_1_0.icx;
    intel-oneapi-classic-compilers_2021_9_0 = intel-oneapi_2023_1_0.icc;
    intel-oneapi-ifort_2021_9_0 = intel-oneapi_2023_1_0.ifort;
    intel-oneapi-tbb_2021_9_0 = intel-oneapi_2023_1_0.tbb;
    intel-oneapi-mpi_2021_9_0 = intel-oneapi_2023_1_0.mpi;
    intel-oneapi-shared_2023_1_0 = intel-oneapi_2023_1_0.shared;

    intel23Stdenv = intel-oneapi_2023_1_0.stdenv;
    intel21Stdenv = intel-oneapi_2023_1_0.stdenv-icc;

    intel-mpi_2019 = callPackage ../pkgs/intel/mpi { };

    ## hello - mirror://gnu/hello/hello-${version}.tar.gz
    hello_2_12_1 = prev.hello.overrideAttrs (old: rec {
      version = "2.12.1";
      src = old.src.overrideAttrs (_: { sha256 = "sha256-jZkUKv2SV28wsM18tCqNxoCZmLxdYH2Idh9RLibH2yA="; });
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
    openmpi_4_1_5_gcc11 = prev.openmpi.override {
      stdenv = prev.gcc11Stdenv;
      gfortran = prev.gfortran11;
    };

    openmpi_4_1_5_intel23 = prev.openmpi.override {
      stdenv = intel23Stdenv;
      fortranSupport = false;
    };

    openmpi_4_1_4_gcc11 = openmpi_4_1_5_gcc11.overrideAttrs (old: rec {
      version = "4.1.4";
      src = old.src.overrideAttrs (_: { hash = "sha256-kpEuF1/RI0NoyHMMA/SZb+WULnR5ux0QBZQF5/Kzkw0="; });
    });

    ## osu-micro-benchmarks - mvapich.cse.ohio-state.edu/download/mvapich/osu-micro-benchmarks-${version}.tar.gz
    osu-micro-benchmarks = osu-micro-benchmarks_5_6_2;

    osu-micro-benchmarks_5_6_2 = callPackage ../pkgs/osu-micro-benchmarks {
      mpi = openmpi_4_1_5_gcc11;
    };

    osu-micro-benchmarks_5_4 = osu-micro-benchmarks.overrideAttrs (old: rec {
      version = "5.4";
      src = old.src.overrideAttrs (_: { sha256 = "sha256-4cp2LhOgcgWlm1mthehc4Pgmtw92/VVc5VaO+x8qjzM="; });
    });

    osu-micro-benchmarks_6_1 = osu-micro-benchmarks.overrideAttrs (old: rec {
      version = "6.1";
      src = old.src.overrideAttrs (_: { sha256 = "sha256-7MztyGgmT3XbTZUpr3kAVBmid1ETx/ro9OSoQ0Ni5Kc="; });
    });

    ## fftw - ftp://ftp.fftw.org/pub/fftw/fftw-${version}.tar.gz
    fftw_3_3_10_gcc11_ompi_4_1_5 = prev.fftw.override {
      stdenv = prev.gcc12Stdenv;
      mpi = openmpi_4_1_5_gcc11;
      enableMpi = true;
    };

    fftw_3_3_10_gcc12_ompi_4_1_4 = prev.fftw.override {
      stdenv = prev.gcc12Stdenv;
      mpi = openmpi_4_1_4_gcc11;
      enableMpi = true;
    };

    fftw_3_3_10_intel21_impi_2019 = prev.fftw.override {
      stdenv = intel21Stdenv;
      mpi = intel-mpi_2019;
      enableMpi = true;
    };

    # LLNL
    adept-utils_1_0_1_gcc11 = callPackage ../pkgs/LLNL/adept-utils {
      stdenv = gcc11Stdenv;
    };

    callpath_1_0_4_gcc11_impi_2019 = callPackage ../pkgs/LLNL/callpath { 
      stdenv = gcc11Stdenv;
      mpi = intel-mpi_2019;
      adept-utils = adept-utils_1_0_1_gcc11;
    };

    mpileaks_1_0_gcc11_impi_2019 = callPackage ../pkgs/LLNL/mpileaks {
      stdenv = gcc11Stdenv;
      adept-utils = adept-utils_1_0_1_gcc11;
      callpath = callpath_1_0_4_gcc11_impi_2019;
      # mpi is inherited from callpath
    };

    # JSC
    sionlib_1_7_7_gcc10_impi_2019 = callPackage ../pkgs/JSC/SIONlib {
      cctype = "gnu";
      mpitype = "intel2";
      stdenv = gcc11Stdenv;
      fortran = prev.gfortran11;
      mpi = intel-mpi_2019;
      enablePython = true;
      python = prev.python311;
    };

    hdf5_gcc12_impi_2021 = callPackage ../pkgs/HDF5 {
      stdenv = gcc12Stdenv;
      mpiSupport = true;
      mpi = intel-oneapi-mpi_2021_9_0;
      fortranSupport = true;
      fortran = prev.gfortran12;
    };

    hdf5_gcc11_ompi_4_1_4 = callPackage ../pkgs/HDF5 {
      stdenv = gcc11Stdenv;
      mpiSupport = true;
      mpi = openmpi_4_1_4_gcc11;
      fortranSupport = true;
      fortran = prev.gfortran11;
    };

    hdf5_intel21_impi_2019 = callPackage ../pkgs/HDF5 {
      stdenv = intel21Stdenv;
      mpiSupport = true;
      mpi = intel-mpi_2019;
    };

    cgns_4_4_0_gcc12_impi_2021 = callPackage ../pkgs/CGNS {
      stdenv = gcc12Stdenv;
      hdf5 = hdf5_gcc12_impi_2021;
      fortranSupport = true;
      fortran = prev.gfortran12;
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

    bupc_2022_10_0_intel23_impi_2021 = callPackage ../pkgs/bupc {
      stdenv = intel23Stdenv;
      mpi = intel-oneapi-mpi_2021_9_0;
    };

    scotch_7_0_3_gcc12_impi_2021 = callPackage ../pkgs/scotch {
      stdenv = gcc12Stdenv;
      fortran = prev.gfortran12;
      mpi = intel-oneapi-mpi_2021_9_0;
    };
  };
}
