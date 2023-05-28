{ pkg, ... }:
{
  libPath = "lib/intel64/gcc4.8";
  libName = "tbb";

  customScriptPath = "${pkg}/env/vars.sh";

  excludes = [
    "PKG_CONFIG_PATH" # is set by the shell script
  ];
}
