import <nixpkgs> rec {
  system = "x86_64-linux";
  overlay = import ./overlay.nix;
  overlays = [ overlay ];
}
