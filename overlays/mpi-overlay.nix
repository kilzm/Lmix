final: prev: rec {
  openmpi_4_1_5 = prev.openmpi.overrideAttrs (old: rec { 
    pname = "openmpi";
    version = "4.1.5";

    src = with prev.lib.versions; prev.fetchurl {
      url = "https://www.open-mpi.org/software/ompi/v${major version}.${minor version}/downloads/${pname}-${version}.tar.bz2";
      sha256 = "sha256-pkCYa8JXOJ3TeYhv2uYmTIz6VryYtxzjrj372M5h2+M=";
    };
  });

  osu-micro-benchmarks = prev.callPackage ../pkgs/osu-micro-benchmarks { 
    mpi = openmpi_4_1_5;
  };

  osu-micro-benchmarks_5_6_2 = osu-micro-benchmarks;

  osu-micro-benchmarks_5_4 = osu-micro-benchmarks.overrideAttrs (old: rec {
    pname = "osu-micro-benchmarks";
    version = "5.4";
    src = prev.fetchurl {
      url = "mvapich.cse.ohio-state.edu/download/mvapich/${pname}-${version}.tar.gz";
      sha256 = "sha256-4cp2LhOgcgWlm1mthehc4Pgmtw92/VVc5VaO+x8qjzM=";
    };
  });

  osu-micro-benchmarks_6_1 = osu-micro-benchmarks.overrideAttrs (old: rec {
    pname = "osu-micro-benchmarks";
    version = "6.1";
    src = prev.fetchurl {
      url = "mvapich.cse.ohio-state.edu/download/mvapich/${pname}-${version}.tar.gz";
      sha256 = "sha256-7MztyGgmT3XbTZUpr3kAVBmid1ETx/ro9OSoQ0Ni5Kc=";
    };
  });
}
