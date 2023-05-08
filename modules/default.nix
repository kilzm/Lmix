{ stdenv
, lib
, pkg
, compiler ? ""
, compilerVer ? 0
, addLDLibPath ? false
}:


with lib;

assert (builtins.typeOf compilerVer) == "int";
assert compiler == ""
  || compiler == "gcc" && 1 <= compilerVer && compilerVer <= 12
  || compiler == "intel" && 19 <= compilerVer && compilerVer <= 23;

stdenv.mkDerivation rec {
  builder = ./builder.sh;

  pkgName = pkg.pname;
  pname = "module-${pkgName}";
  version = pkg.version;

  hasMpi = builtins.hasAttr "mpi" pkg && pkg.mpi != null;
  ompi = hasMpi && pkg.mpi.pname == "openmpi";
  impi = hasMpi && pkg.mpi.pname == "intelmpi";
  withOpenMP = builtins.hasAttr "withOpenMP" pkg && pkg.withOpenMP;

  modName =
    "${pkgName}/${version}"
    + strings.optionalString (compiler != "") "-${compiler}${builtins.toString compilerVer}"
    + strings.optionalString ompi "-ompi"
    + strings.optionalString impi "-impi"
    + strings.optionalString withOpenMP "-openmp"
    + ".lua";

  buildInputs = [ pkg ];
}
