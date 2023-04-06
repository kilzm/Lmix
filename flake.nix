{
  description = "a nix overlay with builtin support for environment modules from lmod";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs?ref=nixos-22.11;
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      overlays = [
        (import ./overlay.nix)
        (import ./julia-overlay.nix)
      ];
      overlay = with nixpkgs.lib; (foldl' composeExtensions (_: _: {}) overlays);
      pkgs = import nixpkgs {
        inherit system;
      };
    in {
      packages.${system} = overlay pkgs pkgs;
      legacyPackages.${system} = nixpkgs.legacyPackages.${system};
    };
}
