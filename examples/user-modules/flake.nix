{
  description = "User defined modules";

  inputs.lmix.url = path:/home/kilianm/lmix;
  inputs.nixpkgs.follows = "lmix/nixpkgs";
  inputs.nixpkgs-unstable.url = github:NixOS/nixpkgs?nixos-unstable;
  inputs.qchem = {
    url = github:Nix-QChem/NixOS-QChem?release-23.05;
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, lmix, nixpkgs, nixpkgs-unstable, qchem }:
    let
      system = "x86_64-linux";
      config = {
        allowUnfree = true;
        permittedInsecurePackages = [
          "python-2.7.18.6"
        ];       
      };

      pkgs = import nixpkgs {
        inherit system config;
        overlays = [ 
          lmix.overlays.mod
          qchem.overlays.qchem
        ];
      };

      unstable = import nixpkgs-unstable {
        inherit system;
      };

      my = import ./. { inherit pkgs unstable; };
    in
    {
      packages.${system} = my.packages // my.modules;
    };
}