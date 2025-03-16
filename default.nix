{ pkgs ? import <nixpkgs> {}, system ? builtins.currentSystem, sources ? null }:

let
  _sources = if sources != null then sources else import ./sources.nix { inherit pkgs; };
  
  version = _sources.typescript-go.version;
  
  fetchTypescriptGo = { version, sha256 }:
    pkgs.fetchFromGitHub {
      owner = "microsoft";
      repo = "typescript-go";
      rev = version;
      inherit sha256;
      fetchSubmodules = true; # Critical: initializes the TypeScript submodule automatically
    };

in pkgs.stdenv.mkDerivation rec {
  pname = "typescript-go";
  inherit version;
  
  src = fetchTypescriptGo {
    inherit version;
    sha256 = _sources.typescript-go.sha256;
  };
  
  nativeBuildInputs = with pkgs; [
    go_1_24
    nodejs_22
    git
  ];
  
  buildInputs = [];
  
  setupPhase = ''
    export HOME=$TMPDIR
    npm ci
  '';
  
  buildPhase = ''
    export HOME=$TMPDIR
    ./node_modules/.bin/hereby build
  '';
  
  installPhase = ''
    # Create output directory
    mkdir -p $out/bin
    
    # Install the tsgo binary
    install -Dm755 built/local/tsgo $out/bin/tsgo
    
    # Create a directory for the repo content (needed for LSP)
    mkdir -p $out/lib/typescript-go
    cp -r . $out/lib/typescript-go
    
    # Create wrapper for each hereby command
    for cmd in build test install-tools lint format generate; do
      cat > $out/bin/tsgo-$cmd <<EOF
#!/bin/sh
cd $out/lib/typescript-go
./node_modules/.bin/hereby $cmd "\$@"
EOF
      chmod +x $out/bin/tsgo-$cmd
    done
    
    # Create wrapper for LSP
    cat > $out/bin/tsgo-lsp <<EOF
#!/bin/sh
cd $out/lib/typescript-go
# Instructions for setting up the LSP with VS Code or other editors
echo "To use the LSP with VS Code:"
echo "1. Open VS Code in your project: code ."
echo "2. Copy .vscode/launch.template.json to .vscode/launch.json"
echo "3. Press F5 or use Debug: Start Debugging"
echo ""
echo "This will launch a new VS Code instance with the TypeScript-Go language server."
EOF
    chmod +x $out/bin/tsgo-lsp
  '';
  
  phases = [ "unpackPhase" "setupPhase" "buildPhase" "installPhase" ];
  
  meta = with pkgs.lib; {
    description = "An implementation of TypeScript in Go";
    homepage = "https://github.com/microsoft/typescript-go";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = [];
  };
}