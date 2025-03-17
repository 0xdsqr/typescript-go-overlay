{
  description = "TypeScript-Go Development Environment";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    typescript-go-overlay.url = "github:0xdsqr/typescript-go-overlay";
  };
  
  outputs = { self, nixpkgs, typescript-go-overlay }:
    let
      systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in {
      devShells = forAllSystems (system: 
        let
          pkgs = import nixpkgs {
            inherit system;
          };
          # Use the default package from the overlay
          typescript-go = typescript-go-overlay.packages.${system}.default;
        in {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              typescript-go
              nodejs_22
              nodePackages.typescript
              go_1_24
            ];
            
            shellHook = ''
              echo "🟪 TypeScript-Go Development Environment 🟪"
              echo "TypeScript-Go version: $(tsgo --version 2>&1 || echo 'unknown')"
              echo "Node.js version: $(node --version)"
              echo "TypeScript version: $(tsc --version)"
              echo "Go version: $(go version)"
              echo ""
              echo "Available commands:"
              echo "  - tsgo: Run TypeScript-Go"
              echo "  - tsc-go: Run TypeScript compiler via Go"
              echo "  - nix run: Compile and run test.ts"
              echo ""
            '';
          };
        }
      );
      
      apps = forAllSystems (system:
        let
          pkgs = import nixpkgs {
            inherit system;
          };
          typescript-go = typescript-go-overlay.packages.${system}.default;
          runTypeScript = pkgs.writeShellScriptBin "run-typescript" ''
            set -e
            echo "📝 Compiling TypeScript with TypeScript-Go..."
            ${typescript-go}/bin/tsc-go test.ts
            echo "🚀 Running the compiled JavaScript..."
            ${pkgs.nodejs_22}/bin/node test.js
          '';
        in {
          default = {
            type = "app";
            program = "${runTypeScript}/bin/run-typescript";
          };
        }
      );
    };
}