#!/bin/bash
set -e

# Get parameters
VERSION=$1

echo "Building aria2 v${VERSION} for Linux"

# Create build directory
mkdir -p build
cd build

# Install dependencies
sudo apt update
sudo apt install -y \
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
    libssl-dev \
    libgnutls28-dev \
    libc-ares-dev \
    libsqlite3-dev \
    zlib1g-dev \
    libssh2-1-dev \
    libexpat1-dev \
    liblzma-dev

# Soft link libcares static library
arch=$(uname -m)
lib_path=$(find /usr/lib -type d | grep "$arch-linux-gnu" | head -n 1)
sudo ln -s "$lib_path/libcares_static.a" "$lib_path/libcares.a"

# Download aria2 source
wget "https://github.com/aria2/aria2/releases/download/release-${VERSION}/aria2-${VERSION}.tar.gz"
tar -xzf "aria2-${VERSION}.tar.gz"
cd "aria2-${VERSION}"

# Configure with static options
./configure \
    ARIA2_STATIC=yes \
    --enable-static \
    --without-gnutls \
    --with-openssl \
    --without-libgcrypt \
    --with-libssh2 \
    --with-sqlite3 \
    --with-libz

# Build
make -j$(nproc)

# Strip binary to reduce size
strip src/aria2c
