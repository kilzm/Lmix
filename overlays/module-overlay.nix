final: prev:
let
  modulesFunc = recSet: cc: name: mods:
    let
      inherit (prev.lib.attrsets) optionalAttrs;
      inherit (builtins) removeAttrs;
      callModule = m:
        let
          attrName = m.mod;
          pkg = if recSet == null then prev.${attrName} else prev.${recSet}.${attrName};
          configAttrs = optionalAttrs (name != null)
            (import ../modules/${name} {
              lib = prev.lib;
              inherit pkg cc;
            });
          extraAttrs = removeAttrs m [ "mod" ];
          modAttrs = { inherit attrName pkg cc; } // extraAttrs // configAttrs;
        in
        prev.callPackage ../modules modAttrs;
    in
    map callModule mods;

  defaultModulesNixpkgs = modulesFunc null "" null;
  defaultModules = modulesFunc "nwm-pkgs" "" null;
  namedModulesNixpkgs = modulesFunc null "";
  namedModules = modulesFunc "nwm-pkgs" "";
  namedCCModules = modulesFunc "nwm-pkgs";
in
{

  nwm-mods = {
    # modules
    _modules-nixpkgs = prev.buildEnv {
      name = "modules-nixpkgs";
      paths = defaultModulesNixpkgs [
        { mod = "ffmpeg"; }
        { mod = "git"; }
        { mod = "valgrind"; incPath = "include/valgrind"; }
        { mod = "llvm"; libName = "LLVM"; }
        { mod = "eigen"; incPath = "include/eigen3"; }
        { mod = "libmatheval"; libName = "matheval"; }
        { mod = "libxc"; libName = "xc"; }
        { mod = "libint"; libName = "int2"; }
        { mod = "blas"; }
        { mod = "lapack"; }
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
        { mod = "python37"; }
        { mod = "python39"; }
        { mod = "python311"; }
      ];
    };

    _modules = prev.buildEnv {
      name = "modules";
      paths = defaultModules [
        { mod = "nix-stdenv"; }
        { mod = "julia_1_9_0"; }
        { mod = "julia_1_8_5"; }
        { mod = "osu-micro-benchmarks_5_6_2"; }
        { mod = "osu-micro-benchmarks_6_1"; }
      ]
      ++ namedModules "openmpi" [
        { mod = "openmpi_4_1_4_gcc11"; cc = "gcc11"; }
        { mod = "openmpi_4_1_5_gcc11"; cc = "gcc11"; }
      ]
      ++ namedModules "fftw" [
        { mod = "fftw_3_3_10_gcc11_ompi_4_1_5"; cc = "gcc11"; }
        { mod = "fftw_3_3_10_gcc12_ompi_4_1_5_openmp"; cc = "gcc12"; }
        { mod = "fftw_3_3_10_intel21"; cc = "intel21"; }
      ]
      ++ namedModules "intel/oneapi-compilers" [
        { mod = "intel-compilers_2022_1_0"; }
      ]
      ++ namedModules "intel/oneapi-tbb" [
        { mod = "intel-tbb_2021_6_0"; }
      ]
      ++ namedModules "intel/oneapi-mpi" [
        { mod = "intel-oneapi-mpi_2021_6_0_gcc11"; cc = "gcc11"; }
      ]
      ++ namedModules "intel/oneapi-mpi" [
        { mod = "intel-oneapi-mpi_2021_6_0_intel21"; cc = "intel21"; }
      ];
    };

    lmod2flake = prev.callPackage ../lmod2flake { };
  };
}
