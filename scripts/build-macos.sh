#!/bin/bash
set -e

# Get parameters
VERSION=$1

echo "Building aria2 v${VERSION} for macOS"

# Create build directory
mkdir -p build
cd build

# Install dependencies with Homebrew
brew update
brew install \
    autoconf \
    automake \
    libtool \
    cppunit \
    zlib \
    libxml2

# Download aria2 source
wget "https://github.com/aria2/aria2/releases/download/release-${VERSION}/aria2-${VERSION}.tar.gz"
tar -xzf "aria2-${VERSION}.tar.gz"
cd "aria2-${VERSION}"

# Configure with static options
./configure \
    ARIA2_STATIC=yes \
    --enable-static \
    --with-libuv

# Build
make -j$(sysctl -n hw.ncpu)

# Strip binary to reduce size
strip src/aria2c
