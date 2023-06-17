{
  description = "Flake that uses lmix overlay";

  inputs.lmix.url = github:kilzm/lmix;

  outputs = { self, lmix }:
    let
      system = "x86_64-linux";
      pkgs = lmix.legacyPackages.${system};
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
