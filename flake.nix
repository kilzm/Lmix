{
  description = "a nix overlay with builtin support for environment modules from lmod";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs?ref=nixos-22.11;
    nurl.url = github:nix-community/nurl;
  };

  outputs = { self, nixpkgs, nurl }:
    let
      system = "x86_64-linux";
      overlay = import ./overlay.nix;
      pkgs = import nixpkgs {
        inherit system;
      };
    in {
      packages.${system} = overlay pkgs pkgs;
      devShell.${system} = pkgs.mkShell rec {
        buildInputs = [
          nurl.packages.${system}.default
        ];
      };
      legacyPackages.${system} = nixpkgs.legacyPackages.${system};
    };
}
