# flake.nix
{
  description = "TypeScript-Go - An implementation of TypeScript in Go";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };
  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachSystem ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"] (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        
        # Import the sources.json for versioning
        sources = builtins.fromJSON (builtins.readFile ./sources.json);
        
        # Create an overlay for TypeScript-Go
        typescript-go-overlay = final: prev: {
          # Latest nightly build of TypeScript-Go
          typescript-go-nightly = final.callPackage ./default.nix {
            sourceInfo = sources.typescript-go-nightly;
          };
        };
      in
      {
        # Overlays for use in other flakes
        overlays.default = typescript-go-overlay;
        
        # Packages for direct use
        packages = {
          # Default is the nightly version for now
          default = pkgs.callPackage ./default.nix {
            sourceInfo = sources.typescript-go-nightly;
          };
          
          # Nightly build explicitly named
          typescript-go-nightly = pkgs.callPackage ./default.nix {
            sourceInfo = sources.typescript-go-nightly;
          };
        };
        
        # Apps for direct execution with nix run
        apps = {
          default = {
            type = "app";
            program = "${self.packages.${system}.default}/bin/tsgo";
          };
        };
        
        # Development shell with all dependencies
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            go_1_24
            nodejs_20
            git
            jq
            curl
          ];
          
          shellHook = ''
            echo "TypeScript-Go development environment"
            echo ""
            echo "Commands:"
            echo "  ./update.sh            - Update sources.json with latest TypeScript-Go"
            echo ""
          '';
        };
        
        formatter = pkgs.nixpkgs-fmt;
      }
    );
}