let
  modulesFunc = { pkgs, set ? null, recSet ? null, name ? null }: mods:
    let
      inherit (pkgs.lib) attrsets strings;
      userModules = set != null;
      callModule = m:
        let
          attrName = m.mod;
          pkg = if userModules
            then set.${attrName}
            else if recSet == null
              then pkgs.${attrName}
              else pkgs.${recSet}.${attrName};
          configAttrs = attrsets.optionalAttrs (name != null)
            (import ../modules/${name} {
              inherit pkg;
              lib = pkgs.lib;
              cc = m.cc or "";
            });
          extraAttrs = builtins.removeAttrs m [ "mod" "nixHook" ];
          modAttrs = {
            inherit pkg;
            attrName = if userModules then ""
              else strings.optionalString (recSet != null) "${recSet}." + (m.nixHook or attrName);
          } // extraAttrs // configAttrs;
        in
        pkgs.callPackage ../modules modAttrs;
    in
    map callModule mods;
in
{
  modules = {
    defaultModulesNixpkgs = pkgs: modulesFunc { inherit pkgs; };
    namedModulesNixpkgs = pkgs: name: modulesFunc { inherit pkgs name; };
    inherit modulesFunc;
  };
}