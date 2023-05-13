{ stdenv
, lib
, pkg
, compiler ? ""
, compilerVer ? 0
, libName ? pkg.name
, cpacName ? ""
, addLDLibPath ? false
, extraPkgVariables ? [ ]
, extraEnvVariables ? [ ]
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

  buildInputs = [ pkg ];

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

  hasLibs = builtins.pathExists "${pkg}/lib";
  hasIncs = builtins.pathExists "${pkg}/include";
  hasBin = builtins.pathExists "${pkg}/bin";

  pacName = 
    if cpacName == "" 
      then builtins.replaceStrings ["-"] ["_"] (lib.strings.toUpper pkgName) 
      else cpacName;

  # from lrz documentation
  PAC_BASE = "${pkg}";
  PAC_LIBDIR = if hasLibs then "${PAC_BASE}/lib" else "";
  PAC_LIB = 
    let path = "${PAC_LIBDIR}/lib${libName}.a"; 
    in if builtins.pathExists path then path else "";
  PAC_SHLIB =
    let path = "${PAC_LIBDIR}/lib${libName}.so";
    in if builtins.pathExists path then "-L${PAC_LIBDIR} -l${libName}" else "";
  PAC_INC = if hasIncs then "-I${PAC_BASE}/include" else "";
  PAC_BIN = if hasBin then "${PAC_BASE}/bin" else "";
}
