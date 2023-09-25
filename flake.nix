{
  description = "a nix overlay with builtin support for environment modules from lmod";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs?ref=23.05;
    nurl.url = github:nix-community/nurl;
    utils.url = github:numtide/flake-utils;
  };

  outputs = inputs@{ self, nixpkgs, nurl, utils }:
    let
      inherit (nixpkgs) lib;
      system = "x86_64-linux";

      config = {
        allowUnfree = true;
        permittedInsecurePackages = [
          "python-2.7.18.6"
        ];
      };

      localSystem = {
        gcc.arch = "skylake";
        gcc.tune = "skylake";
        inherit system;
      };

      pkgs = import nixpkgs {
        inherit system config;
        # inherit localSystem config;

        overlays = [ mod-ovl ];
      };

      hpc-ovl = import ./overlays/hpc-overlay.nix;
      mod-ovl = import ./default.nix;
    in
    {
      overlays = {
        hpc = hpc-ovl;
        mod = mod-ovl;
        default = self.overlays.hpc;
      };

      formatter.${system} = pkgs.nixpkgs-fmt;

      packages.${system} = pkgs.lmix-mods // pkgs.lmix-pkgs;

      legacyPackages.${system} = pkgs;

      devShells.${system}.default = pkgs.mkShell rec {
        packages = [
          nurl.packages.${system}.default
        ];
      };

      templates = {
        default = {
          path = ./template/default;
          description = "Flake that uses lmix overlay";
        };
      };
    };
}
