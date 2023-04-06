# nix-with-modules
A nix overlay that integrates with lmod environment modules.

## Usage

Build a package defined in overlays
```
cd nix-with-modules
nix build .#package-name
```
or
```
nix build github:kilzm/nix-with-modules#package-name
```

Show available packages
```bash
nix flake show [--legacy]
```
