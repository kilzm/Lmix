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
  || compiler == "intel" && 19 <= compilerVer && compilerVer <= 21;

stdenv.mkDerivation rec {
  builder = ./builder.sh;

  pkgName = pkg.pname;
  pname = "module-${pkgName}";
  version = pkg.version;

  ompi = builtins.hasAttr "mpi" pkg && pkg.mpi.pname == "openmpi";
  impi = builtins.hasAttr "mpi" pkg && pkg.mpi.pname == "intelmpi";
  withOpenMP = builtins.hasAttr "withOpenMP" pkg && pkg.withOpenMP;
  
  modName =
    "${pkgName}/${version}"
    + strings.optionalString (compiler != "") "-${compiler}${builtins.toString compilerVer}"
    + strings.optionalString  ompi "-ompi"
    + strings.optionalString impi "-impi"
    + strings.optionalString withOpenMP "-openmp"
    + ".lua";

  buildInputs = [ pkg ];
}
