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
        
        sources = builtins.fromJSON (builtins.readFile ./sources.json);
        
        typescript-go-overlay = final: prev: {
          typescript-go-nightly = final.callPackage ./default.nix {
            sourceInfo = sources.typescript-go-nightly;
          };
        };
      in
      {
        overlays.default = typescript-go-overlay;
        
        packages = {
          default = pkgs.callPackage ./default.nix {
            sourceInfo = sources.typescript-go-nightly;
          };
          
          typescript-go-nightly = pkgs.callPackage ./default.nix {
            sourceInfo = sources.typescript-go-nightly;
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
            nodejs_22
            git
            jq
            curl
          ];
          
          shellHook = ''
            echo "bingbong"
          '';
        };
        
        formatter = pkgs.nixpkgs-fmt;
      }
    );
}