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
            pkg-config
          ];
        };

      packages.${system}.default = pkgs.lmix-pkgs.intel23Stdenv.mkDerivation {
        pname = "pauli-eigens";
        version = "1.0";
        src = ./.;

        buildInputs = with pkgs; [
          eigen
        ];

        nativeBuildInputs = with pkgs; [
          pkg-config
        ];

        installPhase = ''
          mkdir -p $out/bin
          mv pauli_eigens $out/bin
        '';
      };
    };

  nixConfig = {
    bash-prompt-prefix = ''\033[0;36m\[(nix develop)\033[0m '';
  };
}
