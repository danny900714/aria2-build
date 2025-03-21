#!/bin/bash
set -e

# Get parameters
VERSION=$1
ARCH=$2

echo "Building aria2 v${VERSION} for Linux ${ARCH}"

# Create build directory
mkdir -p build
cd build

# Install dependencies
sudo apt-get update
sudo apt-get install -y \
    build-essential \
    git \
    autoconf \
    automake \
    autotools-dev \
    autopoint \
    libtool \
    pkg-config \
    libcppunit-dev \
    libxml2-dev \
    libgcrypt-dev \
    libssl-dev:arm64 \
    libgnutls28-dev \
    libc-ares-dev \
    libsqlite3-dev \
    zlib1g-dev \
    libssh2-1-dev \
    libexpat1-dev

# For ARM64 cross-compilation
if [ "$ARCH" = "arm64" ]; then
    sudo apt-get install -y \
        gcc-aarch64-linux-gnu \
        g++-aarch64-linux-gnu
    
    export CC=aarch64-linux-gnu-gcc
    export CXX=aarch64-linux-gnu-g++
    EXTRA_CONFIG="--host=aarch64-linux-gnu"
fi

# Download aria2 source
wget "https://github.com/aria2/aria2/releases/download/release-${VERSION}/aria2-${VERSION}.tar.gz"
tar -xzf "aria2-${VERSION}.tar.gz"
cd "aria2-${VERSION}"

# Configure with static options
./configure \
    ${EXTRA_CONFIG} \
    --prefix=/usr \
    --disable-shared \
    --enable-static \
    --without-libxml2 \
    --without-gnutls \
    --with-openssl \
    --without-libgcrypt \
    --with-libcares \
    --with-libssh2 \
    --with-sqlite3 \
    --with-libz

# Build
make -j$(nproc)

# Strip binary to reduce size
if [ "$ARCH" = "arm64" ]; then
    aarch64-linux-gnu-strip src/aria2c
else
    strip src/aria2c
fi

# Copy binary to output directory
cd ../..
mkdir -p build
cp "build/aria2-${VERSION}/src/aria2c" "build/aria2-${VERSION}-linux-${ARCH}"

echo "Build completed: build/aria2-${VERSION}-linux-${ARCH}"
