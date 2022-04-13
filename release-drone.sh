#!/bin/bash
VERSIONS=(6.2 7.0)
ARCHS=(
    "apollolake"
    "armada38x"
    "avoton"
    "braswell"
    "broadwell"
    "broadwellnk"
    "bromolow"
    "cedarview"
    "denverton"
    "geminilake"
    "kvmx64"
    "monaco"
    "rtd1296"
    "x64"
)

set -e

# Download all necessary tarballs before calling into the docker containers.
echo "Downloading environment tarballs"
for ver in ${VERSIONS[@]}; do
    url_base="https://sourceforge.net/projects/dsgpl/files/toolkit/DSM$ver"
    mkdir -p /toolkit_tarballs
    if [ ! -f base_env-$ver.txz ]; then
        wget -q --show-progress "$url_base/base_env-$ver.txz"
    fi
    for arch in ${ARCHS[@]}; do
        if [ ! -f ds.$arch-$ver.dev.txz ]; then
            wget -q --show-progress "$url_base/ds.$arch-$ver.dev.txz"
        fi
        if [ ! -f ds.$arch-$ver.env.txz ]; then
            wget -q --show-progress "$url_base/ds.$arch-$ver.env.txz"
        fi
    done
done

for ver in ${VERSIONS[@]}; do
    # Create release directory if needed
    mkdir -p /target/$ver

    for arch in ${ARCHS[@]}; do
        echo "Building '$arch'"

        # Remove old artifact directory
        if [ -d /artifacts/ ]; then
            rm -rf /artifacts/
        fi
        export PACKAGE_ARCH=$arch
        export DSM_VER=$ver
        ./build.sh

        mv /artifacts/WireGuard-*/* /target/$ver/
    done
done

# Clean up artifact directory
if [ -d /artifacts/ ]; then
    rm -rf /artifacts/
fi
