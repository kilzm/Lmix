{ stdenv
, lib
, pkg
, pkgName ? pkg.pname
, compiler ? ""
, compilerVer ? 0
, libName ? pkg.name
, customPacName ? ""
, addLDLibPath ? false
, extraPkgVariables ? ""
, extraEnvVariables ? ""
, jq
}:

with lib;
with lib.strings;

assert (builtins.typeOf compilerVer) == "int";
assert compiler == ""
  || compiler == "gcc" && 7 <= compilerVer && compilerVer <= 13
  || compiler == "intel" && 19 <= compilerVer && compilerVer <= 23;

stdenv.mkDerivation rec {
  builder = ./builder.sh;

  pname = "module-${pkgName}";
  version = pkg.version;

  nativeBuildInputs = [ jq ];
  
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
    if customPacName == ""
    then builtins.replaceStrings [ "-" ] [ "_" ] (toUpper pkgName)
    else customPacName;

  # from lrz documentation
  PAC_BASE = "${pkg}";

  PAC_LIBDIR = optionalString hasLibs "${PAC_BASE}/lib";

  PAC_LIB = 
    let path = "${PAC_LIBDIR}/lib${libName}.a"; 
    in optionalString (builtins.pathExists path) path;

  PAC_SHLIB =
    let path = "${PAC_LIBDIR}/lib${libName}.so";
    in optionalString (builtins.pathExists path) "-L${PAC_LIBDIR} -l${libName}";

  PAC_PTHREADS_LIB =
    let path = "${PAC_LIBDIR}/lib${libName}_threads.a";
    in optionalString (builtins.pathExists path) path;

  PAC_PTHREADS_SHLIB =
    let path = "${PAC_LIBDIR}/lib${libName}_threads.so";
    in optionalString (builtins.pathExists path) "-L${PAC_LIBDIR} -l${libName}_threads";

  PAC_MPI_LIB =
    let path = "${PAC_LIBDIR}/lib${libName}_mpi.a";
    in optionalString (builtins.pathExists path) path;

  PAC_MPI_SHLIB =
    let path = "${PAC_LIBDIR}/lib${libName}_mpi.so";
    in optionalString (builtins.pathExists path) "${PAC_LIBDIR} -l${libName}_mpi";

  PAC_INC = optionalString hasIncs "-I${PAC_BASE}/include";

  PAC_BIN = optionalString hasBin "${PAC_BASE}/bin";

  inherit extraPkgVariables extraEnvVariables;
}
