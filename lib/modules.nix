let
  modulesFunc = { pkgs, recSet ? "", set ? null, name ? "" }: mods:
    let
      callModule = m: let
        pkg = if set != null then set.${m.mod} 
          else if recSet == "" then pkgs.${m.mod} 
          else pkgs.${recSet}.${m.mod};
        attrName = "${if recSet != "" then "${recSet}." else ""}${m.nixHook or m.mod}";
        configAttrs = if (name == "") then {} else
          (import ../modules/${name} { inherit pkg; lib = pkgs.lib; cc = m.cc or ""; });
        extraAttrs = builtins.removeAttrs m [ "mod" "nixHook" ];
        modAttrs = { inherit pkg attrName; } // extraAttrs // configAttrs;
      in pkgs.callPackage ../modules modAttrs;
    in map callModule mods;
in
{
  modules = {
    defaultModulesNixpkgs = pkgs: modulesFunc { inherit pkgs; };
    namedModulesNixpkgs = pkgs: name: modulesFunc { inherit pkgs name; };
    inherit modulesFunc;
  };
}