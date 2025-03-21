#!/bin/bash
set -e

# Get parameters
VERSION=$1

echo "Building aria2 v${VERSION} for macOS ${ARCH}"

# Create build directory
mkdir -p build
cd build

# Install dependencies with Homebrew
brew update
brew install \
    autoconf \
    automake \
    libtool \
    pkg-config \
    cppunit \
    openssl@3 \
    c-ares \
    libssh2 \
    sqlite \
    zlib \
    gettext \
    expat

# Set up environment for cross-compilation if needed
# if [ "$ARCH" = "arm64" ]; then
#     export CFLAGS="-arch arm64"
#     export CXXFLAGS="-arch arm64"
#     export LDFLAGS="-arch arm64"
#     EXTRA_CONFIG="--host=aarch64-apple-darwin"
# else
#     export CFLAGS="-arch x86_64"
#     export CXXFLAGS="-arch x86_64"
#     export LDFLAGS="-arch x86_64"
# fi

# Set PKG_CONFIG_PATH for Homebrew packages
export PKG_CONFIG_PATH="/usr/local/opt/openssl@3/lib/pkgconfig:/usr/local/opt/sqlite/lib/pkgconfig:/usr/local/opt/libssh2/lib/pkgconfig"

# Download aria2 source
wget "https://github.com/aria2/aria2/releases/download/release-${VERSION}/aria2-${VERSION}.tar.gz"
tar -xzf "aria2-${VERSION}.tar.gz"
cd "aria2-${VERSION}"

# Configure with static options
./configure \
    ${EXTRA_CONFIG} \
    --prefix=/usr/local \
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
make -j$(sysctl -n hw.ncpu)

# Strip binary to reduce size
strip src/aria2c

# Copy binary to output directory
cd ../..
mkdir -p build
cp "build/aria2-${VERSION}/src/aria2c" "build/aria2-${VERSION}-macos-${ARCH}"

echo "Build completed: build/aria2-${VERSION}-macos-${ARCH}"
