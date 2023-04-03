final: prev: {
  hello = prev.hello.overrideAttrs (finalAttrs: previousAttrs: {
    version = "2.9";
    src = prev.fetchurl {
      url = "mirror://gnu/hello/hello-${final.hello.version}.tar.gz";
      sha256 = "sha256-7Lt6IhQZbFf/k0CqcUWOFVmr049tjRaWZoRpNd8ZHqc=";
    };
  });
}
