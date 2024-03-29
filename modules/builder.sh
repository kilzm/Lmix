source $stdenv/setup

shopt -s nullglob

modfile="$out/$modfileSuffix"
mkdir -p `dirname "$modfile"`

modPrependPath () {
  echo -e "prepend_path(\"$1\", \"$2\")" >> $modfile
}

modPrependPathIfExists () {
  if [[ -d "$2" && " $excludes " != *" $1 "* ]] ; then
      modPrependPath $1 $2
  fi
}

modOtherFun () {
  echo -e "$1($(echo $2 | sed 's/ /", "/g; s/^/"/; s/$/"/'))" >> $modfile
}

modSetEnv () {
  echo -e "setenv(\"$1\", \"$2\")" >> $modfile
}

addPaths () {
  modPrependPathIfExists "PATH" "$1/bin"
  modPrependPathIfExists "MANPATH" "$1/share/man"
  modPrependPathIfExists "PKG_CONFIG_PATH" "$1/lib/pkgconfig"
  modPrependPathIfExists "PKG_CONFIG_PATH" "$1/share/pkgconfig"
  modPrependPathIfExists "CMAKE_PREFIX_PATH" "$1/lib/cmake"
  modPrependPathIfExists "CMAKE_PREFIX_PATH" "$1/share/cmake"
  modPrependPathIfExists "PERL5LIB" "$1/lib/perl5/site_perl"
  modPrependPathIfExists "ACLOCAL_PATH" "$1/share/aclocal"

  libs=($1/lib/lib*.so)
  if [[ $addLDLibPath && -n $libs ]] ; then
    modPrependPath "LD_LIBRARY_PATH" "$1/lib"
  fi
}

addPkgVariables () {
  # PAC_BASE - base nix store path
  modSetEnv "${pacName}_BASE" "$BASE"
  # PAC_BIN - bin directory
  if [[ -d "$BINDIR" && " $excludes " != *" BIN "* ]] ; then
    modSetEnv "${pacName}_BIN" "$BINDIR"
  fi
  # PAC_LIBDIR - library directory
  if [[ -d "$LIBDIR" && " $excludes " != *" LIBDIR "* ]]; then
    modSetEnv "${pacName}_LIBDIR" "$LIBDIR"
  fi
  # PAC_LIB - setting for static linking
  if [[ -f "$LIBSTATIC" && " $excludes " != *" LIB "* ]] ; then
    modSetEnv "${pacName}_LIB" "$LIBSTATIC"
  fi
  # PAC_SHLIB - setting for dynamic linking
  if [[ -f "$LIBSHARED" && " $excludes " != *" LIB "* ]] ; then
    modSetEnv "${pacName}_SHLIB" "-L$LIBDIR -l$libName"
  fi
  # PAC_INC - include directory
  if [[ -d "$INCDIR" && " $excludes " != *" INC "* ]] ; then
    modSetEnv "${pacName}_INC" "-I$INCDIR"
  fi

  keys=$(jq -r 'keys[]' <<< "$extraPkgVariables")
  for key in $keys ; do
    val=$(jq --arg key "$key" --raw-output '.[$key]' <<< "$extraPkgVariables")
    modSetEnv "${pacName}_$key" "$val"
  done
}

cat > $modfile << EOF
-- $modName
-- autogenerated by lmix

local pkgName = myModuleName()
local version = myModuleVersion()

depends_on("nix-stdenv/${pkgsver}")
EOF

if [[ -n "$WHATIS" ]] ; then
  echo "whatis(\"$WHATIS\")" >> $modfile
fi

modSetEnv "LMIX_${pkgNameUpper}_ATTRNAME" "${attrName}"
modSetEnv "LMIX_${pkgNameUpper}_NATIVE" "${NATIVE}"

if [[ -n "$CCSTDENV" ]] ; then
  modSetEnv "LMIX_${pkgNameUpper}_STDENV" "${CCSTDENV}"
fi

echo >> $modfile

if [[ -n "$customModfilePath" ]]; then
  moddir="$(dirname $customModfilePath)"
  modname="$(basename $customModfilePath)"
  modPrependPath "MODULEPATH" "$moddir"
  echo -e "load(\"$modname\")" >> $modfile
fi

if [[ -n "$customScriptPath" ]]; then
  echo -e "source_sh(\"bash\", \"$customScriptPath\")" >> $modfile
fi

if [[  -n "$dependencies" ]] ; then
  modOtherFun "depends_on" "$dependencies"
fi

if [[ -n "$conflicts" ]] ; then
  modOtherFun "conflict" "$conflicts"
fi

if [[ -n "$prerequisites" ]] ; then
  modOtherFun "prereq" "$prerequisites"
fi

if [[ -n "$prerequisitesAny" ]] ; then
  modOtherFun "prereq_any" "$prerequisitesAny"
fi

addPaths $singleOutputPkg

echo >> $modfile

if [[ -n "$extraLua" ]] ; then
  echo "$extraLua" >> $modfile
  echo >> $modfile
fi

addPkgVariables

echo >> $modfile

keys=$(jq -r 'keys[]' <<< "$extraEnvVariables")
for key in $keys ; do
  val=$(jq --arg key "$key" --raw-output '.[$key]' <<< "$extraEnvVariables")
  modSetEnv "$key" "$val"
done