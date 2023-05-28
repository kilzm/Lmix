{ ... }:
{
  # otherwise module name would be gcc-wrapper
  pkgName = "gcc";

  extraPkgVariables = builtins.toJSON {
    WWW = "https://doku.lrz.de/display/PUBLIC/GNU+Compiler+Collection";
  };
}
