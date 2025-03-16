#!/usr/bin/env nix-shell
#! nix-shell -p curl jq -i bash
set -e

echo "Updating TypeScript-Go versions..."

# Create a starter sources.json if it doesn't exist or is empty
if [ ! -s sources.json ]; then
  echo "Initializing sources.json..."
  echo '{}' > sources.json
fi

# ----- Update TypeScript-Go Nightly -----
# Get latest commit from TypeScript-Go main branch
LATEST_COMMIT=$(curl -s "https://api.github.com/repos/microsoft/typescript-go/commits/main" | jq -r '.sha')
echo "Latest commit: ${LATEST_COMMIT}"

# Get current commit from sources.json 
CURRENT_COMMIT=$(jq -r '.["typescript-go-nightly"].commit // "none"' sources.json)
echo "Current commit: ${CURRENT_COMMIT}"

# Check if we already have the latest commit
if [ "$LATEST_COMMIT" = "$CURRENT_COMMIT" ]; then
  echo "Already at latest commit: ${LATEST_COMMIT}"
  exit 0
fi

# Get current date for versioning
CURRENT_DATE=$(date +%Y-%m-%d)

# Download the latest tarball to compute hash
TARBALL_URL="https://github.com/microsoft/typescript-go/archive/${LATEST_COMMIT}.tar.gz"
curl -sL "${TARBALL_URL}" -o typescript-go-latest.tar.gz

# Compute SHA256 hash
SHA256=$(nix-hash --type sha256 --flat typescript-go-latest.tar.gz)
echo "SHA256: ${SHA256}"

# Create a temporary file with the new entries
cat > sources.new.json << EOF
{
  "typescript-go-nightly": {
    "version": "${LATEST_COMMIT}",
    "sha256": "${SHA256}",
    "url": "${TARBALL_URL}",
    "date": "${CURRENT_DATE}",
    "commit": "${LATEST_COMMIT}"
  },
  "nightly-${CURRENT_DATE}": {
    "version": "${LATEST_COMMIT}",
    "sha256": "${SHA256}",
    "url": "${TARBALL_URL}",
    "date": "${CURRENT_DATE}",
    "commit": "${LATEST_COMMIT}"
  }
}
EOF

# Make a backup of the current sources.json
cp sources.json sources.old.json

# Merge the new entries with the existing file
jq -s '.[0] * .[1]' sources.json sources.new.json > sources.json.tmp
mv sources.json.tmp sources.json

echo "Updated TypeScript-Go nightly to commit ${LATEST_COMMIT} (${CURRENT_DATE})"

# Clean up
rm -f typescript-go-latest.tar.gz sources.new.json