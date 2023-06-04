{ stdenv
, lib
, buildEnv
, attrName
, pkg
, pkgName ? pkg.pname or pkg.name
, version ? pkg.version or ""

  # this will be set in the overlay if the specific compiler and its version are relevant to the module like in fftw
, cc ? ""

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
, binPath ? "bin"
, incPath ? "include"
, libPath ? "lib"

  # specify if the libdir should be added to the LD_LIBRARY_PATH
, addLDLibPath ? false

  # json parser
, jq
}:

with lib;
with lib.strings;

let
  multiPackage = builtins.length pkg.outputs > 1;
  monoPkg =
    if multiPackage
    then
      buildEnv
        {
          name = pkg.name;
          paths = map (out: pkg.${out}) pkg.outputs;
        }
    else pkg;
in

stdenv.mkDerivation rec {
  builder = ./builder.sh;

  inherit pkgName attrName libName;
  inherit extraPkgVariables extraEnvVariables;
  inherit customModfilePath customScriptPath;
  inherit dependencies excludes addLDLibPath;

  pname = "module-${pkgName}";
  inherit version;

  buildInputs = [ monoPkg ];

  nativeBuildInputs = [ jq ];
  
  hasMpi = (pkg.mpi or null) != null;
  ompi = hasMpi && pkg.mpi.pname == "openmpi";
  impi = hasMpi && pkg.mpi.pname == "intel-mpi";
  withOpenMP = pkg.withOpenMP or false;

  modName =
    if
      version != ""
    then
      "${pkgName}/${version}"
      + strings.optionalString (cc != "") "-${cc}"
      + strings.optionalString ompi "-ompi"
      + strings.optionalString impi "-impi"
      + strings.optionalString withOpenMP "-openmp"
      + ".lua"
    else
      "${pkgName}.lua";


  pkgNameUpper = builtins.replaceStrings [ "-" ] [ "_" ] (toUpper pkgName);

  pacName =
    if customPacName == "" then pkgNameUpper else customPacName;

  BASE = monoPkg;
  BINDIR = "${BASE}/${binPath}";
  INCDIR = "${BASE}/${incPath}";
  LIBDIR = "${BASE}/${libPath}";
  LIBSTATIC = "${LIBDIR}/lib${libName}.a";
  LIBSHARED = "${LIBDIR}/lib${libName}.so";
}
