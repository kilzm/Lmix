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
in
rec { 
  inherit packages;

  modules = {
    my-modules = pkgs.buildEnv {
      name = "myMods";
      paths = defaultModulesNixpkgs pkgs [
        { mod = "python310"; }
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
      ];
    };
  };
}