{ stdenv
, pkg
}:

stdenv.mkDerivation rec {
  builder = ./builder.sh;

  pname = "module-${pkgName}";
  version = pkg.version;

  pkgName = pkg.pname;
  modName = "${pkgName}/${version}.lua";

  buildInputs = [ pkg ];
}
