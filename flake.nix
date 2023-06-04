{
  description = "a nix overlay with builtin support for environment modules from lmod";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs?ref=nixos-23.05;
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
          "qtwebkit-5.212.0-alpha4"
          "python-2.7.18.6"
        ];
      };
      pkgs = import nixpkgs {
        inherit system config;
        overlays = [ mod-ovl ];
      };

      hpc-ovl = import ./overlays/overlay.nix;
      mod-ovl = import ./default.nix;
    in
    {
      overlays = {
        hpc = hpc-ovl;
        mod = mod-ovl;
        default = self.overlays.hpc;
      };

      formatter.${system} = pkgs.nixpkgs-fmt;

      packages.${system} = pkgs.nwm-mods // pkgs.nwm-pkgs;

      apps.${system} = {
        lmod2flake = {
          type = "app";
          program = "${self.packages.${system}.lmod2flake}/bin/lmod2flake";
        };
        default = self.apps.${system}.lmod2flake;
      };

      legacyPackages.${system} = pkgs;

      devShells.${system}.default = pkgs.mkShell rec {
        buildInputs = [
          nurl.packages.${system}.default
        ];
      };

      templates = {
        default = {
          path = ./template/default;
          description = "Flake that uses nix-with-modules overlay";
        };

        no-build-inputs = {
          path = ./template/lmod2flake;
          description = "Used by the lmod2flake program";
        };
      };
    };
}
