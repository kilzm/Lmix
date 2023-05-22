{
  description = "Flake that uses nix-with-modules overlay";
  
  inputs = {
    nix-with-modules.url = github:kilzm/nix-with-modules;
    nixpkgs.url = github:nixos/nixpkgs?ref=nixos-22.11;
  };

  outputs = { self, nixpkgs, nix-with-modules }: 
  let 
  system = "x86_64-linux";
  config = nix-with-modules.config;
  pkgs = import nixpkgs {
    inherit system config;
    overlays = [ nix-with-modules.overlays.default ];
  };
  in
  {
    devShells.${system}.default = pkgs.mkShell rec {
      buildInputs = with pkgs; with pkgs.nwm-pkgs; [
        # required packages go here
      ];
    };
  };
}

