#!/bin/sh

set -e

NODE_VERSION="14.21.3"
NUM_CORES=$(nproc || echo 2)

echo "init"

apk add --no-cache \
  bash curl wget ca-certificates \
  make gcc g++ python3 \
  libc-dev linux-headers > /dev/null 2>&1

cd /usr/local/src > /dev/null 2>&1
mkdir -p node-build && cd node-build > /dev/null 2>&1
curl -sLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION.tar.gz"

tar -xzf "node-v$NODE_VERSION.tar.gz" > /dev/null 2>&1
cd "node-v$NODE_VERSION"

./configure > /dev/null 2>&1
make -j"$NUM_CORES" > /dev/null 2>&1
make install > /dev/null 2>&1

cd /
rm -rf /usr/local/src/node-build

echo "done"