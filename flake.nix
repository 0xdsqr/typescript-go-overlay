{
  description = "🟪 typescript-go-overlay 🦉";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };
  outputs = { self, nixpkgs, flake-utils, ... }: 
    let
      # Import sources.json
      sources = builtins.fromJSON (builtins.readFile ./sources.json);
      
      # Define systems to support
      systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
      
      # System-specific outputs
      outputs = flake-utils.lib.eachSystem systems (system:
        let
          pkgs = import nixpkgs {
            inherit system;
          };
        in
        {
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
      });
    in
      outputs
      // {
        # Define overlay at the top level, outside eachSystem
        overlays.default = final: prev: {
          typescript-go-nightly = final.callPackage ./default.nix {
            sourceInfo = sources.typescript-go-nightly;
          };
        };
        
        # Templates
        templates.typescript-go = {
          path = ./templates/typescript-go;
          description = "A basic TypeScript-Go development environment.";
        };
      };
}