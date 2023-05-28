{ pkg, ... }:
{
  libName = "ruby-${pkg.version.majMinTiny}";
  incPath = "include/ruby-${pkg.version.majMin}.0";
}
