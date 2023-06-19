{
  description = "Flake that uses lmix overlay";

  inputs.lmix.url = github:kilzm/lmix;

  outputs = { self, lmix }:
    let
      system = "x86_64-linux";
      pkgs = lmix.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell.override
        {
          stdenv = pkgs.lmix-pkgs.intel23Stdenv;
        }
        rec {
          buildInputs = with pkgs; [
            eigen
          ];
          nativeBuildInputs = with pkgs; [
            bear
            pkg-config
          ];
        };
    };

  nixConfig = {
    bash-prompt-prefix = ''\033[0;36m\[(nix develop)\033[0m '';
  };
}
