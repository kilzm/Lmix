final: prev:
  let
    overlays = map import (prev.lib.filesystem.listFilesRecursive ./overlays);
    overlay = with prev.lib; foldl' composeExtensions (_: _: {}) overlays;
  in
     overlay final prev
