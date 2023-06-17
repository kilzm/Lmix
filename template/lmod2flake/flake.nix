{
  description = "Used by the lmod2flake program";

  inputs.lmix.url = github:kilzm/lmix;

  outputs = { self, lmix }:
    let
      system = "x86_64-linux";
      pkgs = lmix.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell.override {
      } rec {
        buildInputs = with pkgs; [
        ];
        nativeBuildInputs = with pkgs; [
        ];
      };
    };

  nixConfig = {
    bash-prompt-prefix = ''\033[0;36m\[(nix develop)\033[0m '';
  };
}
