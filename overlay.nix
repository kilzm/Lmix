final: prev:
  let
    overlays = [
      (import ./overlays/misc-overlay.nix)
      (import ./overlays/julia-overlay.nix)
    ];
    overlay = with prev.lib; foldl' composeExtensions (_: _: {}) overlays;
  in
     overlay final prev
