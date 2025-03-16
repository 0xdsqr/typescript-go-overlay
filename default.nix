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
    echo "setup phase..."
    echo "Source directory contents:"
    ls -la
    
    # Verify submodules
    echo "Checking submodules:"
    ls -la _submodules
    
    # Check specifically for the TypeScript submodule
    if [ -d "_submodules/TypeScript" ]; then
      echo "TypeScript submodule exists"
      echo "TypeScript submodule contents:"
      ls -la _submodules/TypeScript | head
    else
      echo "ERROR: TypeScript submodule is missing!"
      exit 1
    fi
    
    # Create npm cache directory within the build directory
    mkdir -p .npm-cache
    export npm_config_cache=$(pwd)/.npm-cache
    export HOME=$(pwd)
    
    # Install npm dependencies 
    echo "Installing npm dependencies..."
    npm ci --verbose
  '';
  
  buildPhase = ''
    echo "build phase..."
    
    # Make sure npm uses the same cache directory
    export npm_config_cache=$(pwd)/.npm-cache
    export HOME=$(pwd)
    
    # Use hereby to build the project
    echo "Running hereby build..."
    ./node_modules/.bin/hereby build
  '';
  
  installPhase = ''
    echo "install phase..."
    mkdir -p $out/bin
    
    # Copy the built binary to the output
    if [ -f "built/local/tsgo" ]; then
      echo "Copying tsgo binary to $out/bin"
      cp -v built/local/tsgo $out/bin/tsgo
      chmod +x $out/bin/tsgo
    else
      echo "ERROR: built/local/tsgo not found!"
      echo "Contents of built directory (if it exists):"
      ls -la built || echo "built directory does not exist"
      exit 1
    fi
  '';
  
  # Make sure the phases run in the right order
  phases = [ "unpackPhase" "setupPhase" "buildPhase" "installPhase" ];
  
  meta = with lib; {
    description = "An implementation of TypeScript in Go";
    homepage = "https://github.com/microsoft/typescript-go";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = [];
  };
}