# nix-with-modules
A nix overlay that integrates with lmod environment modules.

## Usage

To build a package defined in overlay.nix
```
cd nix-with-modules
nix build .#[packageName]
./result/bin/[packageName]
```

To show available packages
```
nix flake show
```
