{
  description = "User defined modules";

  inputs.lmix.url = path:/home/kilianm/lmix;

  inputs.nixpkgs.follows = "lmix/nixpkgs";

  inputs.nixpkgs-unstable.url = github:NixOS/nixpkgs?nixos-unstable;

  outputs = { self, lmix, nixpkgs, nixpkgs-unstable }:
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
        overlays = [ lmix.overlays.mod ];
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