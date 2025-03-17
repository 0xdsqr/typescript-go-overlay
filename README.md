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

## Thanks

Project structure was taken from this [zig-overlay](https://github.com/mitchellh/zig-overlay/tree/main) as a base thanks @Mitchell Hashimoto.