{ stdenv
, lib
, symlinkJoin
, attrName
, pkg
, pkgName ? pkg.pname or pkg.name
, version ? pkg.version

  # this will be set in the overlay if the specific compiler and its version are relevant to the module like in fftw
, cc ? ""

, mpiFlv ? ""
, omp ? false

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

  # add extra lua code for more complicated logic
, extraLua ? ""

  # specify which other modules the module depends on
, dependencies ? [ ]
, prerequisites ? [ ]
, prerequisitesAny ? [ ]

  # exclude environment/package variables that would otherwise be automatically created
  # sometimes PAC_LIBDIR might be unnecessary or adding to PATH is handled by sourced script
, excludes ? [ ]

  # module will only load if these are not loaded
, conflicts ? [ ]

  # false will ignore all package variables for lib
, pkgLib ? true

  # false will ignore the PAC_INC variable
, pkgInc ? true

  # default is the standard for packages but some might ignore these
  # e.g. set libPath = "lib/intel64"
, binPath ? "bin"
, incPath ? "include"
, libPath ? "lib"

  # short description of the module
, whatis ? ""

  # set environment variable for lmod2flake
, native ? false  # belongs in nativeBuildInputs
, ccStdenv ? ""   # corresponding stdenv to compiler package

  # specify if the libdir should be added to the LD_LIBRARY_PATH
, addLDLibPath ? false

  # json parser
, jq
}:

with lib;
with lib.strings;
with lib.lists;

assert cc != "" -> elem cc ["intel" "gcc" "intel21" "intel23" "gcc7" "gcc8" "gcc9" "gcc10" "gcc11" "gcc12"];
assert mpiFlv != "" -> elem mpiFlv ["impi" "ompi"];

stdenv.mkDerivation rec {
  builder = ./builder.sh;

  inherit pkgName attrName libName;
  inherit extraPkgVariables extraEnvVariables;
  inherit customModfilePath customScriptPath extraLua;
  inherit dependencies prerequisites prerequisitesAny conflicts;
  inherit excludes addLDLibPath;

  pname = "module-${pkgName}";
  inherit version;

  singleOutputPkg = if length pkg.outputs > 1
    then symlinkJoin {
      name = pkg.name;
      paths = map (out: pkg.${out}) pkg.outputs;
    } else pkg;
  
  nativeBuildInputs = [ jq ];
 
  modName = let
    ccstr = if cc != "" then "-${cc}" else "";
    mpistr = if mpiFlv != "" then "-${mpiFlv}"
      else if (pkg.mpi or null) == null then ""
      else if (hasPrefix pkg.mpi.pname "openmpi") then "-ompi"
      else if (hasPrefix pkg.mpi.pname "intel") then "-impi" else "";
    ompstr = if (pkg.withOpenMP or false) || omp then "-openmp" else "";
  in "${pkgName}/${version}${ccstr}${mpistr}${ompstr}.lua";
  
  pkgsver = import ../pkgs-ver.nix;
  modfileSuffix = "lmix_${pkgsver}/${modName}";

  pkgNameUpper = replaceStrings [ "-" ] [ "_" ] (toUpper pkgName);

  pacName = if customPacName == "" then pkgNameUpper else customPacName;

  WHATIS = if whatis != "" then whatis else replaceStrings [ "\n" ] [ " " ] pkg.meta.description or "";

  NATIVE = if native then "1" else "0";
  CCSTDENV = ccStdenv;

  BASE = singleOutputPkg;
  BINDIR = "${BASE}/${binPath}";
  INCDIR = "${BASE}/${incPath}";
  LIBDIR = "${BASE}/${libPath}";
  LIBSTATIC = "${LIBDIR}/lib${libName}.a";
  LIBSHARED = "${LIBDIR}/lib${libName}.so";
}
