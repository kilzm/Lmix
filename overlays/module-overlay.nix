final: prev: rec {
  modules = prev.buildEnv {
    name = "modules";
    paths = map (pkg: prev.callPackage ../modules {
      inherit pkg;
    }) (with final; [
      R
      julia   
    ]);
  };
}
