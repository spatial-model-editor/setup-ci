#!/bin/bash

# ./get-libs.sh sme_deps_version sme_deps_common_version sme_deps_qt_version sme_deps_llvm_version
# where each x_version can be:
#   - "skip": do nothing
#   - "latest": download latest version
#   - "YYYY.MM.DD": download version with tag YYYY.MM.DD

set -e -x

if [[ $RUNNER_OS == "Linux" ]] && [[ $RUNNER_ARCH == "X64" ]]; then
    OS="linux"
elif [[ $RUNNER_OS == "Linux" ]] && [[ $RUNNER_ARCH == "ARM64" ]]; then
    OS="linux-arm64"
elif [[ $RUNNER_OS == "macOS" ]] && [[ $RUNNER_ARCH == "X64" ]]; then
    OS="osx"
elif [[ $RUNNER_OS == "macOS" ]] && [[ $RUNNER_ARCH == "ARM64" ]]; then
    OS="osx-arm64"
elif [[ $RUNNER_OS == "Windows" ]]; then
    OS="win64-mingw"
fi

BUILD_TAG=$5

HAVE_FILES_TO_INSTALL=false

download_dep() {
    # first arg must be one of "sme_deps_llvm", "sme_deps_qt", "sme_deps_common" or "sme_deps"
    DEP=$1
    # second arg must be either "skip" to do nothing, "latest" or a tagged version to download
    VERSION=$2

    if [[ $VERSION == "skip" ]]; then
        echo "Skipping ${DEP} download"
        return 0
    fi

    if [[ $VERSION == "latest" ]]; then
        URL=https://github.com/spatial-model-editor/${DEP}/releases/latest/download/${DEP}_${OS}${BUILD_TAG}.tgz
    else
        URL="https://github.com/spatial-model-editor/${DEP}/releases/download/${VERSION}/${DEP}_${OS}${BUILD_TAG}.tgz"
    fi

    echo "Downloading ${VERSION} ${DEP}${BUILD_TAG} for ${OS}"
    wget "${URL}"
    tar xf "${DEP}_${OS}${BUILD_TAG}.tgz"
    HAVE_FILES_TO_INSTALL=true
}

download_dep "sme_deps" "$1"
download_dep "sme_deps_common" "$2"
download_dep "sme_deps_qt" "$3"
download_dep "sme_deps_llvm" "$4"

if [[ $HAVE_FILES_TO_INSTALL == true ]]; then
    # copy libs to desired location: workaround for tar -C / not working on msys2
    if [[ $OS == "win64-mingw" ]]; then
        mv c/smelibs /c/
    else
        ${SUDO_CMD} mv opt/* /opt/
    fi
fi
