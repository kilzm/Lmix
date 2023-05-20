{ stdenv
, lib
, buildEnv
, attrName
, pkg
, pkgName ? if builtins.hasAttr "pname" pkg then pkg.pname else pkg.name

  # these will be set in the overlay if the specific compiler and version are relevant to the module like in fftw
, compiler ? ""
, compilerVer ? 0

  # modify this when the library files are not called "lib<pkgName>.a"/"lib<pkgName>.so" 
, libName ? pkgName

  # specify a custom prefix for the package variables e.g. PACNAME_BASE
  # if empty the prefix will be the package name uppercase with '_' instead of '-'
, customPacName ? ""

  # specify extra package variables in JSON format which is supported by builtins.toJSON <attrset>
  # the package prefix will be added so defining e.g. WWW = "..." is sufficient
, extraPkgVariables ? ""

  # specify extra environment variables in JSON format
, extraEnvVariables ? ""

  # if the compiled package provide a premade modulefile it can be loaded here
  # supports both TCL and lua/LMod modules
, customModfilePath ? ""

  # if the compiled package provides premade script to set the env it can be sourced here
, customScriptPath ? ""

  # specify which other modules the module depends on
, dependencies ? [ ]

  # exclude environment/package variables that would otherwise be automatically created
  # sometimes PAC_LIBDIR might be unnecessary or adding to PATH is handled by sourced script
, excludes ? [ ]

  # false will ignore all package variables for lib
, pkgLib ? true

  # false will ignore the PAC_INC variable
, pkgInc ? true

  # default is the standard for packages but some might ignore these
  # e.g. set libPath = "lib/intel64"
, incPath ? "include"
, libPath ? "lib"

  # specify if the libdir should be added to the LD_LIBRARY_PATH
, addLDLibPath ? false

  # json parser
, jq
}:

with lib;
with lib.strings;

assert (builtins.typeOf compilerVer) == "int";
assert compiler == ""
  || compiler == "gcc" && 7 <= compilerVer && compilerVer <= 13
  || compiler == "intel" && 19 <= compilerVer && compilerVer <= 23;

let
  monoPkg =
    if builtins.length pkg.outputs > 1
    then
      buildEnv
        {
          name = pkg.name;
          paths = map (out: pkg.${out}) pkg.outputs;
        } else pkg;
in

stdenv.mkDerivation rec {
  builder = ./builder.sh;
  
  inherit pkgName attrName;
  inherit extraPkgVariables extraEnvVariables;
  inherit customModfilePath customScriptPath;
  inherit dependencies excludes addLDLibPath;

  pname = "module-${pkgName}";
  version = if builtins.hasAttr "version" pkg then pkg.version else "";

  buildInputs = [ monoPkg ];

  nativeBuildInputs = [ jq ];

  hasMpi = builtins.hasAttr "mpi" pkg && pkg.mpi != null;
  ompi = hasMpi && pkg.mpi.pname == "openmpi";
  impi = hasMpi && pkg.mpi.pname == "intelmpi";
  withOpenMP = builtins.hasAttr "withOpenMP" pkg && pkg.withOpenMP;

  modName =
    if
      version != ""
    then
      "${pkgName}/${version}"
      + strings.optionalString (compiler != "") "-${compiler}${builtins.toString compilerVer}"
      + strings.optionalString ompi "-ompi"
      + strings.optionalString impi "-impi"
      + strings.optionalString withOpenMP "-openmp"
      + ".lua"
    else
      "${pkgName}.lua";

  hasLibs = builtins.pathExists "${pkg}/lib";
  hasIncs = builtins.pathExists "${pkg}/include";
  hasBin = builtins.pathExists "${pkg}/bin";
  
  pkgNameUpper = builtins.replaceStrings [ "-" ] [ "_" ] (toUpper pkgName);

  pacName =
    if customPacName == "" then pkgNameUpper else customPacName;

  # from lrz documentation
  PAC_BASE = "${pkg}";

  PAC_LIBDIR = optionalString (pkgLib && hasLibs) "${PAC_BASE}/${libPath}";

  PAC_LIB =
    let path = "${PAC_LIBDIR}/lib${libName}.a";
    in optionalString (pkgLib && builtins.pathExists path) path;

  PAC_SHLIB =
    let path = "${PAC_LIBDIR}/lib${libName}.so";
    in optionalString (pkgLib && builtins.pathExists path) "-L${PAC_LIBDIR} -l${libName}";

  PAC_PTHREADS_LIB =
    let path = "${PAC_LIBDIR}/lib${libName}_threads.a";
    in optionalString (pkgLib && builtins.pathExists path) path;

  PAC_PTHREADS_SHLIB =
    let path = "${PAC_LIBDIR}/lib${libName}_threads.so";
    in optionalString (pkgLib && builtins.pathExists path) "-L${PAC_LIBDIR} -l${libName}_threads";

  PAC_MPI_LIB =
    let path = "${PAC_LIBDIR}/lib${libName}_mpi.a";
    in optionalString (pkgLib && builtins.pathExists path) path;

  PAC_MPI_SHLIB =
    let path = "${PAC_LIBDIR}/lib${libName}_mpi.so";
    in optionalString (pkgLib && builtins.pathExists path) "${PAC_LIBDIR} -l${libName}_mpi";

  PAC_INC = optionalString (pkgInc && hasIncs) "-I${PAC_BASE}/${incPath}";

  PAC_BIN = optionalString hasBin "${PAC_BASE}/bin";
}
