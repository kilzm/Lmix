{ ... }:
{
  libName = "fftw3";

  extraPkgVariables = builtins.toJSON {
    WWW = "https://doku.lrz.de/display/PUBLIC/FFTW+-+Fastest+Fourier+Transform+in+the+West";
  };
}
