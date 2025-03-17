{ pkgs, lib ? pkgs.lib, sourceInfo }:
pkgs.stdenv.mkDerivation rec {
  pname = "typescript-go";
  version = sourceInfo.version;
  src = pkgs.fetchgit {
    url = "https://github.com/microsoft/typescript-go.git";
    rev = sourceInfo.commit or sourceInfo.version;
    sha256 = sourceInfo.sha256; # Will be updated by --update-input
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
    [ -d "internal/bundled/libs" ] || { echo "ERROR: Bundled TypeScript definitions are missing!"; exit 1; }
    
    mkdir -p .npm-cache
    export npm_config_cache=$(pwd)/.npm-cache
    export HOME=$(pwd)
    
    npm ci
  '';
  buildPhase = ''
    export npm_config_cache=$(pwd)/.npm-cache
    export HOME=$(pwd)
    ./node_modules/.bin/hereby build
  '';
installPhase = ''
  mkdir -p $out/bin
  mkdir -p $out/lib
  mkdir -p $out/share/typescript-go
  find internal/bundled/libs -name "*.d.ts" -exec cp -v {} $out/lib/ \;
  for file in $out/lib/*.d.ts; do
    ln -sv "$file" $out/bin/
  done
  if [ -f "built/local/tsgo" ]; then
    cp -v built/local/tsgo $out/bin/tsgo
    chmod +x $out/bin/tsgo
  else
    echo "ERROR: built/local/tsgo not found!"
    ls -la built/ || echo "built directory does not exist"
    exit 1
  fi
  cat > $out/bin/tsc-go <<EOF
#!/bin/sh
exec $out/bin/tsgo tsc "\$@"
EOF
  chmod +x $out/bin/tsc-go
  cp -v README.md LICENSE CHANGES.md $out/share/typescript-go/ || true
'';
  doCheck = true;
  checkPhase = ''
    ./built/local/tsgo --help > /dev/null
  '';
  phases = [ "unpackPhase" "setupPhase" "buildPhase" "checkPhase" "installPhase" ];
  meta = with lib; {
    description = "An implementation of TypeScript in Go";
    homepage = "https://github.com/microsoft/typescript-go";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = [];
  };
}