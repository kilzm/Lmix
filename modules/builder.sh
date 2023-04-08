source $stdenv/setup

shopt -s nullglob

modfile="$out/modules/$modName"
mkdir -p `dirname "$modfile"`

cat > $modfile << EOF
-- $modName
-- autogenerated by nix-with-modules

local pkgName = myModuleName()
local version = myModuleVersion()
EOF

addPath () {
  echo "local pkg = pathJoin(\"$1\", \"bin\")" >> $modfile
  echo "prepend_path(\"PATH\", pkg)" >> $modfile
}

for i in $buildInputs;
do
  addPath $i
done
