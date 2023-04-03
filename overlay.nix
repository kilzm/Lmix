final: prev: {
  hello_2_12_1 = prev.hello.overrideAttrs (finalAttrs: previousAttrs: rec {
    version = "2.12.1";
    src = prev.fetchurl {
      url = "mirror://gnu/hello/hello-${version}.tar.gz";
      sha256 = "sha256-jZkUKv2SV28wsM18tCqNxoCZmLxdYH2Idh9RLibH2yA=";
    };
  });

  hello_2_9 = prev.hello.overrideAttrs (finalAttrs: previousAttrs: rec {
    version = "2.9";
    src = prev.fetchurl {
      url = "mirror://gnu/hello/hello-${version}.tar.gz";
      sha256 = "sha256-7Lt6IhQZbFf/k0CqcUWOFVmr049tjRaWZoRpNd8ZHqc=";
    };
  });
}
