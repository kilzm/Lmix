{ pkgs, unstable }:
let
  inherit (pkgs) callPackage;
  inherit (pkgs.lib.modules) defaultModulesNixpkgs namedModulesNixpkgs modulesFunc;
  
  packages = {
    my-hello = callPackage ./pkgs/hello { 
      stdenv = pkgs.lmix-pkgs.intel21Stdenv;
    };
  };

  myModules = modulesFunc { set = packages; inherit pkgs; };
  qchemModules = modulesFunc { inherit pkgs; recSet = "qchem"; };
in
rec { 
  inherit packages;

  modules = {
    my-modules = pkgs.buildEnv {
      name = "myMods";
      paths = defaultModulesNixpkgs pkgs [
        { mod = "clang"; }
        { mod = "libff"; libName = "ff"; }
        { mod = "glib"; libName = "glib-2.0"; }
      ]
      ++ defaultModulesNixpkgs unstable [
        { mod = "slurm"; }
      ]
      ++ namedModulesNixpkgs pkgs "gcc" [
        { mod = "gcc49"; ccStdenv = "gcc49Stdenv"; }
      ]
      ++ myModules [
        { mod = "my-hello"; }
      ]
      ++ qchemModules [
        { mod = "gromacs"; }
        { mod = "fftwSinglePrec"; pkgName = "fftw-single"; }
      ];
    };
  };
}