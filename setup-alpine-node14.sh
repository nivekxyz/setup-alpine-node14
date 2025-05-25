#!/bin/sh

set -e

NODE_VERSION="14.21.3"
NUM_CORES=$(nproc || echo 2)
ARCH="x64"
PKG_NAME="node-v$NODE_VERSION-linux-musl"
STAGING_DIR="/tmp/$PKG_NAME"
OUTPUT_TAR="/tmp/$PKG_NAME.tar.gz"

do_package() {
  echo "📦 Packaging Node.js $NODE_VERSION..."

  rm -rf "$STAGING_DIR"
  mkdir -p "$STAGING_DIR"

  cp -a /usr/local/bin "$STAGING_DIR/"
  cp -a /usr/local/include "$STAGING_DIR/"
  cp -a /usr/local/lib "$STAGING_DIR/"
  cp -a /usr/local/share "$STAGING_DIR/"

  strip "$STAGING_DIR/bin/node" || true

  cd /tmp
  tar -czf "$OUTPUT_TAR" "$PKG_NAME"

  SIZE=$(du -h "$OUTPUT_TAR" | cut -f1)
  echo "🎉 Done packaging: $OUTPUT_TAR ($SIZE)"
}

# Check for --package-only flag
if [ "$1" = "--package-only" ]; then
  do_package
  exit 0
fi

echo "🔧 Installing build dependencies..."
apk add --no-cache \
  bash curl wget ca-certificates \
  make gcc g++ python3 \
  libc-dev linux-headers

# Ensure /usr/local/src exists
mkdir -p /usr/local/src

echo "📦 Downloading Node.js v$NODE_VERSION source..."
cd /usr/local/src
mkdir -p node-build && cd node-build
curl -LO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION.tar.gz"

echo "📂 Extracting..."
tar -xzf "node-v$NODE_VERSION.tar.gz"
cd "node-v$NODE_VERSION"

echo "🔨 Configuring..."
./configure

echo "⚙️ Building (this may take a few minutes)..."
make -j"$NUM_CORES"

echo "✅ Installing..."
make install

echo "🧼 Cleaning up build files..."
cd /
rm -rf /usr/local/src/node-build

echo "🧪 Verifying install..."
node -v
npm -v

# Package the result
do_package