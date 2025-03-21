#!/bin/bash
set -e

# Get parameters
VERSION=$1
ARCH=$2

echo "Building aria2 v${VERSION} for Windows ${ARCH}"

# Set up MSYS2 environment
if [ "$ARCH" = "amd64" ]; then
    MSYSTEM=MINGW64
    MSYS2_ARCH=x86_64
elif [ "$ARCH" = "arm64" ]; then
    MSYSTEM=CLANGARM64
    MSYS2_ARCH=aarch64
else
    echo "Unsupported architecture: ${ARCH}"
    exit 1
fi

# Create build directory
mkdir -p build
cd build

# Download and extract MSYS2
curl -L https://github.com/msys2/msys2-installer/releases/download/2023-07-18/msys2-base-x86_64-20230718.sfx.exe -o msys2.exe
./msys2.exe -y -o.

# Create MSYS2 build script
cat > build-aria2-msys2.sh << 'EOF'
#!/bin/bash
set -e

VERSION=$1
MSYSTEM=$2
MSYS2_ARCH=$3

# Update MSYS2 packages
pacman -Syu --noconfirm

# Install build dependencies
pacman -S --needed --noconfirm \
    $MSYSTEM-gcc \
    $MSYSTEM-make \
    $MSYSTEM-autotools \
    $MSYSTEM-pkg-config \
    $MSYSTEM-openssl \
    $MSYSTEM-c-ares \
    $MSYSTEM-libssh2 \
    $MSYSTEM-sqlite3 \
    $MSYSTEM-zlib \
    $MSYSTEM-expat \
    $MSYSTEM-cppunit \
    git \
    tar \
    wget

# Download aria2 source
wget "https://github.com/aria2/aria2/releases/download/release-${VERSION}/aria2-${VERSION}.tar.gz"
tar -xzf "aria2-${VERSION}.tar.gz"
cd "aria2-${VERSION}"

# Configure with static options
./configure \
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
    --with-libz \
    --enable-mingw

# Build
make -j$(nproc)

# Strip binary to reduce size
strip src/aria2c.exe

# Copy binary to output directory
cp src/aria2c.exe /build/aria2-${VERSION}-windows-${MSYS2_ARCH}.exe
EOF

chmod +x build-aria2-msys2.sh

# Run MSYS2 build script
./msys2_shell.cmd -${MSYSTEM} -defterm -no-start -here -c "./build-aria2-msys2.sh ${VERSION} ${MSYSTEM} ${MSYS2_ARCH}"

# Move binary to expected location
cd ..
mkdir -p build
mv "build/aria2-${VERSION}-windows-${MSYS2_ARCH}.exe" "build/aria2-${VERSION}-windows-${ARCH}.exe"

echo "Build completed: build/aria2-${VERSION}-windows-${ARCH}.exe"
