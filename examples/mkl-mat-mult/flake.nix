{
  description = "Flake that uses nix-with-modules overlay";

  inputs.nix-with-modules.url = github:kilzm/nix-with-modules;

  outputs = { self, nix-with-modules }:
    let
      system = "x86_64-linux";
      pkgs = nix-with-modules.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell.override
        {
          stdenv = pkgs.lmix-pkgs.intel21IFortStdenv;
        }
        rec {
          buildInputs = with pkgs; [
            mkl
          ];
          nativeBuildInputs = with pkgs; [
          ];
          MKL_BASE="${pkgs.mkl}";
        };
    };

  nixConfig = {
    bash-prompt-prefix = ''\033[0;36m\[(nix develop)\033[0m '';
  };
}
