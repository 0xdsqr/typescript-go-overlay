{ pkgs, lib ? pkgs.lib, sourceInfo }:
pkgs.stdenv.mkDerivation rec {
  pname = "typescript-go";
  version = sourceInfo.version;
  src = pkgs.fetchgit {
    url = "https://github.com/microsoft/typescript-go.git";
    rev = sourceInfo.commit or sourceInfo.version;
    sha256 = "sha256-cPu/DdgW7HEQcH8kcu6dazEgHEXsTVMnZ2feqVR5gNA="; # Will be updated by --update-input
    fetchSubmodules = true;
    leaveDotGit = false;
  };
  
  nativeBuildInputs = with pkgs; [
    go_1_24
    nodejs_22
    git
    cacert
  ];
  
  buildInputs = [];
  
  # Environment variables for npm
  NODE_TLS_REJECT_UNAUTHORIZED = "0";
  
  setupPhase = ''
    echo "Setup phase..."
    
    # Verify submodules
    echo "Checking TypeScript submodule..."
    if [ -d "_submodules/TypeScript" ]; then
      echo "✅ TypeScript submodule exists"
    else
      echo "❌ ERROR: TypeScript submodule is missing!"
      exit 1
    fi
    
    # Create npm cache directory within the build directory
    mkdir -p .npm-cache
    export npm_config_cache=$(pwd)/.npm-cache
    export HOME=$(pwd)
    
    # Install npm dependencies 
    echo "Installing npm dependencies..."
    npm ci
  '';
  
  buildPhase = ''
    echo "Build phase..."
    
    # Use the same npm cache
    export npm_config_cache=$(pwd)/.npm-cache
    export HOME=$(pwd)
    
    # Build the project using hereby
    echo "Running hereby build..."
    ./node_modules/.bin/hereby build
  '';
  
  installPhase = ''
    echo "Install phase..."
    
    # Create directory structure
    mkdir -p $out/bin
    mkdir -p $out/lib
    mkdir -p $out/share/typescript-go
    
    # Copy TypeScript library files
    echo "Copying TypeScript library files..."
    cp -rv _submodules/TypeScript/lib/* $out/lib/
    
    # Create symlinks to make the TypeScript lib files accessible where tsgo expects them
    ln -sv $out/lib/lib*.d.ts $out/bin/
    
    # Copy the built binary
    if [ -f "built/local/tsgo" ]; then
      echo "Copying tsgo binary to $out/bin"
      cp -v built/local/tsgo $out/bin/tsgo
      chmod +x $out/bin/tsgo
    else
      echo "ERROR: built/local/tsgo not found!"
      ls -la built/ || echo "built directory does not exist"
      exit 1
    fi
    
    # Create a wrapper script for tsc compatibility mode
    cat > $out/bin/tsc <<EOF
#!/bin/sh
exec $out/bin/tsgo tsc "\$@"
EOF
    chmod +x $out/bin/tsc
    
    # Copy documentation
    cp -v README.md LICENSE CHANGES.md $out/share/typescript-go/
  '';
  
  # Provide a small sanity check to verify the binary works
  doCheck = true;
  checkPhase = ''
    echo "Checking if binary runs..."
    ./built/local/tsgo --help > /dev/null
  '';
  
  # Make sure the phases run in the right order
  phases = [ "unpackPhase" "setupPhase" "buildPhase" "checkPhase" "installPhase" ];
  
  meta = with lib; {
    description = "An implementation of TypeScript in Go";
    homepage = "https://github.com/microsoft/typescript-go";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = [];
  };
}