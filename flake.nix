{
  description = "a nix overlay with builtin support for environment modules from lmod";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs?ref=nixos-22.11;
    nurl.url = github:nix-community/nurl;
    utils.url = github:numtide/flake-utils;
  };

  outputs = inputs@{ self, nixpkgs, nurl, utils }:
    let
      system = "x86_64-linux";
      config = {
        allowUnfree = true;
        permittedInsecurePackages = [
          "qtwebkit-5.212.0-alpha4"
        ];
      };

      hpc-ovl = import ./overlays/overlay.nix;
      mod-ovl = import ./default.nix;
      pkgs = import nixpkgs {
        inherit system config;
        overlays = [ mod-ovl ];
      };
    in
    {
      inherit config;

      overlays = {
        hpc = hpc-ovl;
        mod = mod-ovl;
        default = self.overlays.hpc;
      };

      formatter.${system} = pkgs.nixpkgs-fmt;

      packages.${system} = pkgs.nwm-mods // pkgs.nwm-pkgs;

      legacyPackages.${system} = pkgs;

      devShells.${system}.default = pkgs.mkShell rec {
        buildInputs = [
          nurl.packages.${system}.default
        ];
      };

      templates.default = {
        path = ./template;
        description = "Flake that uses nix-with-modules overlay";
      };
    };
}
