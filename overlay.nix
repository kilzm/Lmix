final: prev: {
  hello_2_12_1 = prev.hello.overrideAttrs (old: rec {
    version = "2.12.1";
    src = prev.fetchurl {
      url = "mirror://gnu/hello/hello-${version}.tar.gz";
      sha256 = "sha256-jZkUKv2SV28wsM18tCqNxoCZmLxdYH2Idh9RLibH2yA=";
    };
  });

  hello_2_9 = prev.hello.overrideAttrs (old: rec {
    version = "2.9";
    src = prev.fetchurl {
      url = "mirror://gnu/hello/hello-${version}.tar.gz";
      sha256 = "sha256-7Lt6IhQZbFf/k0CqcUWOFVmr049tjRaWZoRpNd8ZHqc=";
    };
  });

  julia_1_8_5 = prev.julia_18-bin;
    
  julia_1_9_0 = prev.callPackage ./pkgs/julia/1.9.0-rc2-bin.nix { };
}
