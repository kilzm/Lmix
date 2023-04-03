{
  description = "a nix overlay with builtin support for environment modules from lmod";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs?ref=nixos-22.11;
    flake-utils.url = github:numtide/flake-utils;
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      system = "x86_64-linux";
      overlay = import ./.;
      overlays = {
        default = overlay;
      };
      pkgs = import nixpkgs {
        inherit system;
        overlays = [overlay];
      };
    in {
      packages.${system} = import ./. pkgs pkgs;
    };
}
