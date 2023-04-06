let
  system = "x86_64-linux";
  overlays = [ (import ./overlay.nix) ];
in
  import <nixpkgs> {
    inherit system overlays;
  }
