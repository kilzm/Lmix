{
  description = "Flake that uses nix-with-modules overlay";

  inputs.nix-with-modules.url = github:kilzm/nix-with-modules;

  outputs = { self, nix-with-modules }:
    let
      system = "x86_64-linux";
      pkgs = nix-with-modules.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell.override { 
        # stdenv = pkgs.nwm-pkgs.<stdenv>  
      } rec {
        buildInputs = with pkgs; [
          # required packages go here
        ];
        nativeBuildInputs = with pkgs; [
          # build packages go here
        ];
      };
    };

  nixConfig = {
    bash-prompt-prefix = ''\033[0;36m\[(nix develop)\033[0m '';
  };
}
