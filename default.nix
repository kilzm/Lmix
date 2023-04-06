let
  system = "x86_64-linux";
  overlays = [
    (import ./overlay.nix)
    (import ./julia-overlay.nix)
  ];
in
  import <nixpkgs> {
    inherit system overlays;
  }
