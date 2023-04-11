final: prev: rec {
  
  # hello 
  hello_2_12_1 = prev.hello.overrideAttrs (old: rec {
    version = "2.12.1";
    src = prev.fetchurl {
      url = "mirror://gnu/${old.pname}/${old.pname}-${version}.tar.gz";
      sha256 = "sha256-jZkUKv2SV28wsM18tCqNxoCZmLxdYH2Idh9RLibH2yA=";
    };
  });

  hello_2_9 = prev.hello.overrideAttrs (old: rec {
    version = "2.9";
    src = prev.fetchurl {
      url = "mirror://gnu/${old.pname}/${old.pname}-${version}.tar.gz";
      sha256 = "sha256-7Lt6IhQZbFf/k0CqcUWOFVmr049tjRaWZoRpNd8ZHqc=";
    };
  });
  
  # julia
  julia_1_8_5 = prev.julia_18-bin;
    
  julia_1_9_0 = prev.callPackage ./pkgs/julia/1.9.0-rc2-bin.nix { };

  # openmpi
  openmpi_4_1_5 = prev.openmpi.overrideAttrs (old: rec { 
    version = "4.1.5";

    src = with prev.lib.versions; prev.fetchurl {
      url = "https://www.open-mpi.org/software/ompi/v${major version}.${minor version}/downloads/${old.pname}-${version}.tar.bz2";
      sha256 = "sha256-pkCYa8JXOJ3TeYhv2uYmTIz6VryYtxzjrj372M5h2+M=";
    };
  });

  # osu-micro-benchmark
  osu-micro-benchmarks = prev.callPackage ./pkgs/osu-micro-benchmarks { 
    mpi = openmpi_4_1_5;
  };

  osu-micro-benchmarks_5_6_2 = osu-micro-benchmarks;

  osu-micro-benchmarks_5_4 = osu-micro-benchmarks.overrideAttrs (old: rec {
    version = "5.4";
    src = prev.fetchurl {
      url = "mvapich.cse.ohio-state.edu/download/mvapich/${old.pname}-${version}.tar.gz";
      sha256 = "sha256-4cp2LhOgcgWlm1mthehc4Pgmtw92/VVc5VaO+x8qjzM=";
    };
  });

  osu-micro-benchmarks_6_1 = osu-micro-benchmarks.overrideAttrs (old: rec {
    version = "6.1";
    src = prev.fetchurl {
      url = "mvapich.cse.ohio-state.edu/download/mvapich/${old.pname}-${version}.tar.gz";
      sha256 = "sha256-7MztyGgmT3XbTZUpr3kAVBmid1ETx/ro9OSoQ0Ni5Kc=";
    };
  });

  # modules
  modules = prev.buildEnv {
    name = "modules";
    paths = map (pkg: prev.callPackage ./modules {
      inherit pkg;
    }) (with final; [
      julia_1_9_0
      julia_1_8_5
      openmpi_4_1_5     
      osu-micro-benchmarks_5_6_2
      osu-micro-benchmarks_6_1
    ]);
  };
}
