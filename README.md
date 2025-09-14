# typescript-go-overlay

This project is now archived since A preview build is available on npm as @typescript/native-preview, and owned by the offical development team. Someone could add this to nix node pacakges if they want.

Please do note:

> This project is slow to use,i would not use it right now, built to learn some stuff, i will move it to use go and it will work better, once i have time. As of today it's using herby with npm install (no good for nix)

This repository is a Nix flake packaging the [typescript-go](https://github.com/microsoft/typescript-go) project. The flake tracks and builds Microsoft's TypeScript Go implementation, providing nightly builds based on the latest commit at the time.

* **Nightly Builds**: Automatically tracks the latest commits from typescript-go
* **Easy Integration**: Works with flakes, Home Manager, and direct installation
* **Multi-Platform**: Builds for x86_64-linux, aarch64-linux, and more
* **Consistent Environment**: Ensures reproducible builds with pinned dependencies
* **Simple API**: Follows the same pattern as other popular overlay flakes like zig-overlay

## Usage

### Flake

In your `flake.nix` file:

```nix
{
  inputs.typescript-go-overlay.url = "github:0xdsqr/typescript-go-overlay";
  outputs = { self, typescript-go-overlay, ... }: {
    # Your outputs here
  };
}
```

In a shell:

```sh
# Run the latest nightly version
$ nix run 'github:0xdsqr/typescript-go-overlay'

# Open a shell with the latest nightly version
$ nix shell 'github:0xdsqr/typescript-go-overlay'
```

### Direct Package Usage

You can use typescript-go-overlay directly in your flake, similar to how you might use zig-overlay:

```nix
{
  description = "Your Project";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    typescript-go-overlay.url = "github:0xdsqr/typescript-go-overlay";
  };
  outputs = { self, nixpkgs, typescript-go-overlay }: 
    let
      forAllSystems = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ];
    in {
      # Access in your packages
      packages = forAllSystems (system: {
        default = nixpkgs.legacyPackages.${system}.callPackage ./nix/package.nix {
          typescript-go = typescript-go-overlay.packages.${system}.typescript-go;
        };
      });
      
      # Access in your devShells
      devShells = forAllSystems (system: {
        default = nixpkgs.legacyPackages.${system}.callPackage ./nix/devShell.nix {
          typescript-go = typescript-go-overlay.packages.${system}.typescript-go;
        };
      });
    };
}
```

### Alternative: Using as an Overlay

If you prefer, you can also use typescript-go-overlay as a nixpkgs overlay:

```nix
# In your flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    typescript-go-overlay.url = "github:0xdsqr/typescript-go-overlay";
  };
  
  outputs = { self, nixpkgs, typescript-go-overlay, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ typescript-go-overlay.overlay ];
      };
    in {
      # Now typescript-go is available directly in pkgs
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [ pkgs.typescript-go ];
      };
    };
}
```

### With Home Manager

```nix
# In your home.nix
{ config, pkgs, inputs, ... }:
{
  home.packages = [
    inputs.typescript-go-overlay.packages.${pkgs.system}.typescript-go
  ];
}
```

### Direct Command Line Usage

You can also use it directly without configuration:

```bash
# Install the latest nightly build
nix profile install github:0xdsqr/typescript-go-overlay

# Run typescript-go
tsgo --help

# Use the TypeScript compiler via Go
tsc-go --version
```

## Thanks

Project structure was taken from this flake [zig-overlay](https://github.com/mitchellh/zig-overlay/tree/main) which provides a great baseline for this type of thing, thanks @Mitchell Hashimoto.
