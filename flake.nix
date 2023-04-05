{
  description = "a nix overlay with builtin support for environment modules from lmod";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs?ref=nixos-22.11;
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      overlay = import ./overlay.nix;
      pkgs = import nixpkgs {
        inherit system;
      };
    in {
      packages.${system} = overlay pkgs pkgs;
    };
}
