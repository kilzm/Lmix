final: prev: {
  julia_1_8_5 = prev.julia_18-bin;
    
  julia_1_9_0 = prev.callPackage ./pkgs/julia/1.9.0-rc2-bin.nix { };
}
