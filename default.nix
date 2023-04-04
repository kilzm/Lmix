let
  overlay = import ./overlay.nix;
in
  import <nixpkgs> {
    system = "x86_64-linux";
    overlays = [ overlay ];
  }
