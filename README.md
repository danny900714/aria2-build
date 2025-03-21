# aria2-build

Cross-platform build for download utility aria2 using GitHub Actions.

## Overview

This repository contains GitHub Actions workflows and build scripts to create static builds of [aria2](https://github.com/aria2/aria2) for multiple platforms and architectures:

- Windows (amd64, arm64)
- Linux (amd64, arm64)
- macOS (amd64, arm64)

The builds are fully static, meaning they include all dependencies and can run without requiring additional libraries to be installed on the target system.

## Usage

### Triggering a Build

1. Go to the "Actions" tab in this repository
2. Select the "Build Static aria2" workflow
3. Click "Run workflow"
4. Enter the aria2 version you want to build (default: 1.37.0)
5. Click "Run workflow" to start the build process

### Build Artifacts

After the workflow completes successfully:

1. The binaries will be available as artifacts for each platform/architecture
2. A GitHub release will be created with all binaries attached

### Build Configuration

The aria2 binaries are built with the following configuration:

- Static linking (all dependencies included)
- OpenSSL for TLS support
- libssh2 for SFTP support
- c-ares for asynchronous DNS
- SQLite3 for control file support
- zlib for compression
- libexpat for XML parsing

## Build Scripts

The repository contains three build scripts:

- `scripts/build-linux.sh`: Builds aria2 for Linux (amd64, arm64)
- `scripts/build-macos.sh`: Builds aria2 for macOS (amd64, arm64)
- `scripts/build-windows.sh`: Builds aria2 for Windows (amd64, arm64)

These scripts are used by the GitHub Actions workflow but can also be run locally if you have the necessary build environment set up.

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.
