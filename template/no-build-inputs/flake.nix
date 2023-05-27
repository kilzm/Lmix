{
  description = "Flake that lists devShell dependencies in extraFile";

  inputs = {
    nix-with-modules.url = github:kilzm/nix-with-modules;
  };

  outputs = { self, nixpkgs, nix-with-modules }:
    let
      system = "x86_64-linux";
      pkgs = nix-with-modules.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell rec {
      };
    };
}

