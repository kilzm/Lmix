final: prev:
let
  modulesFunc = attrPrefix: cc: name: mods:
    map
      (m:
        let pkg = if attrPrefix == "" then prev.${m.name} else prev.${attrPrefix}.${m.name};
        in prev.callPackage ../modules ({
          attrName = m.name;
          inherit pkg cc;
        }
        // (if builtins.hasAttr "extra" m then m.extra else { })
        // (if name != "" then
          (import ../modules/${name} {
            lib = prev.lib;
            inherit pkg cc;
          })
        else { })
        )
      )
      mods;

  defaultModulesNixpkgs = modulesFunc "" "" "";
  defaultModules = modulesFunc "nwm-pkgs" "" "";
  namedModulesNixpkgs = modulesFunc "" "";
  namedModules = modulesFunc "nwm-pkgs" "";
  namedCCModules = modulesFunc "nwm-pkgs";
in
{

  nwm-mods = {
    # modules
    _modules-nixpkgs = prev.buildEnv {
      name = "modules-nixpkgs";
      paths = defaultModulesNixpkgs [
        { name = "ffmpeg"; }
        { name = "git"; }
        { name = "valgrind"; extra = { incPath = "include/valgrind"; }; }
        { name = "llvm"; }
        { name = "eigen"; extra = { incPath = "include/eigen3"; }; }
        { name = "libmatheval"; extra = { libName = "matheval"; }; }
        { name = "libxc"; extra = { libName = "xc"; }; }
        { name = "libint"; extra = { libName = "int2"; }; }
        { name = "blas"; }
        { name = "lapack"; }
      ]
      ++ namedModulesNixpkgs "gcc" [
        { name = "gcc7"; }
        { name = "gcc8"; }
        { name = "gcc9"; }
        { name = "gcc10"; }
        { name = "gcc11"; }
        { name = "gcc12"; }
      ]
      ++ namedModulesNixpkgs "ruby" [
        { name = "ruby"; }
      ]
      ++ namedModulesNixpkgs "python" [
        { name = "python2"; }
        { name = "python37"; }
        { name = "python39"; }
        { name = "python311"; }
      ];
    };

    _modules = prev.buildEnv {
      name = "modules";
      paths = defaultModules [
        { name = "nix-stdenv"; }
        { name = "julia_1_9_0"; }
        { name = "julia_1_8_5"; }
        { name = "osu-micro-benchmarks_5_6_2"; }
        { name = "osu-micro-benchmarks_6_1"; }
      ]
      ++ namedModules "openmpi" [
        { name = "openmpi_4_1_4_gcc11"; extra = { cc = "gcc11"; }; }
        { name = "openmpi_4_1_5_gcc11"; extra = { cc = "gcc11"; }; }
      ]
      ++ namedModules "fftw" [
        { name = "fftw_3_3_10_gcc11_ompi_4_1_5"; extra = { cc = "gcc11"; }; }
        { name = "fftw_3_3_10_gcc12_ompi_4_1_5_openmp"; extra = { cc = "gcc12"; }; }
        { name = "fftw_3_3_10_intel21"; extra = { cc = "intel21"; }; }
      ]
      ++ namedModules "intel/oneapi-compilers" [
        { name = "intel-compilers_2022_1_0"; }
      ]
      ++ namedModules "intel/oneapi-tbb" [
        { name = "intel-tbb_2021_6_0"; }
      ]
      ++ namedModules "intel/oneapi-mpi" [
        { name = "intel-oneapi-mpi_2021_6_0_gcc11"; extra = { cc = "gcc11"; }; }
      ]
      ++ namedModules "intel/oneapi-mpi" [
        { name = "intel-oneapi-mpi_2021_6_0_intel21"; extra = { cc = "intel21"; }; }
      ];
    };

    lmod2flake = prev.callPackage ../lmod2flake { };
  };
}
