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
      overlay = import ./default.nix;
      pkgs = import nixpkgs {
        inherit system config;
      };
    in
    {
      inherit overlay;
      formatter.${system} = pkgs.nixpkgs-fmt;
      packages.${system} = overlay pkgs pkgs;
      devShells.${system}.default = pkgs.mkShell rec {
        buildInputs = [
          nurl.packages.${system}.default
        ];
      };
      legacyPackages.${system} = nixpkgs.legacyPackages.${system};
    };
}
