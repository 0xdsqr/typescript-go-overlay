# typescript-go-overlay

This repository is a Nix flake packaging the [typescript-go](https://github.com/microsoft/typescript-go) project. The flake tracks and builds Microsoft's TypeScript Go implementation, providing nightly builds.

## Usage

### Using with Nix Flakes

Add this overlay to your flake inputs:

```nix
# In your flake.nix
{
  inputs.typescript-go-overlay.url = "github:daveved/typescript-go-overlay";

  outputs = { self, typescript-go-overlay, ... }: {
    # Your outputs here
  };
}
```

#### Running the TypeScript-Go Nightly Compiler

```bash
# Run the latest nightly version
$ nix run 'github:daveved/typescript-go-overlay'
# Open a shell with the latest nightly
$ nix shell 'github:daveved/typescript-go-overlay'
# Access a specific dated nightly build (if available)
$ nix shell 'github:daveved/typescript-go-overlay#nightly-2025-03-15'
```

## Thanks

Project structure was taken from [here](https://github.com/mitchellh/zig-overlay/tree/main) as a base. Mitchell Hashimoto's GitHub seems to be a knowledge bank for Nix. Thanks for the learning baseline.