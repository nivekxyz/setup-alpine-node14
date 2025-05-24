#!/bin/sh

set -e

NODE_VERSION="14.21.3"
NUM_CORES=$(nproc || echo 2)

echo "🔧 Installing build dependencies..."
apk add --no-cache \
  bash curl wget ca-certificates \
  make gcc g++ python3 \
  libc-dev linux-headers

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

echo "🧼 Cleaning up..."
cd /
rm -rf /usr/local/src/node-build

echo "🧪 Verifying install..."
node -v
npm -v