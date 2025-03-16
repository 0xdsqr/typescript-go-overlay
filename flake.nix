{
  description = "TypeScript-Go - An implementation of TypeScript in Go";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    # Used for shell.nix
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
        
        sources = builtins.fromJSON (builtins.readFile ./sources.json);
        
        typescript-go-overlay = final: prev: {
          typescript-go-nightly = final.callPackage ./default.nix {
            sources = {
              typescript-go = sources["typescript-go-nightly"];
            };
          };
          
          typescript-go-dated = 
            builtins.mapAttrs 
              (name: value: 
                if builtins.match "nightly-.*" name != null then
                  final.callPackage ./default.nix {
                    sources = {
                      typescript-go = value;
                    };
                  }
                else null
              )
              (builtins.removeAttrs sources ["typescript-go" "typescript-go-nightly"]);
        };
      in
      {
        overlays.default = typescript-go-overlay;
        
        packages = {
          default = pkgs.callPackage ./default.nix {
            sources = {
              typescript-go = sources["typescript-go-nightly"];
            };
          };
          
          typescript-go-nightly = pkgs.callPackage ./default.nix {
            sources = {
              typescript-go = sources["typescript-go-nightly"];
            };
          };
        };
        
        apps = {
          default = {
            type = "app";
            program = "${self.packages.${system}.default}/bin/tsgo";
          };
        };
        
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
            echo "After cloning TypeScript-Go:"
            echo "  git submodule update --init --recursive"
            echo "  npm ci"
            echo "  hereby build"
          '';
        };
        
        formatter = pkgs.nixpkgs-fmt;
      }
    );
}