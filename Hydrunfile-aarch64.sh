#!/bin/bash

apt update

apt install -y g++-10-aarch64-linux-gnu binutils-gold-aarch64-linux-gnu libstdc++-10-dev-arm64-cross

DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends python3-dev python3-pip ninja-build clang-10 llvm-10-dev libomp-10-dev sed curl wget git

yes | pip3 install --upgrade cmake

cd /tmp
export url=$(curl -s https://api.github.com/repos/llvm/llvm-project/releases/latest | grep "tarball_url" | cut -d '"' -f 4,4)
wget -O latest.tar.gz $url
tar -zxf latest.tar.gz
export llvm=$(find . -type d -name *llvm* -print)

export version=$(curl -s https://api.github.com/repos/llvm/llvm-project/releases/latest | grep "tag_name" | cut -d '"' -f 4,4 | cut -d '-' -f 2)

# Edit for Clangd to work with Jupyter .ipynb
sed -i "265i\\\t   .Case(\"ipynb\", TY_CXX)" /tmp/$llvm/clang/lib/Driver/Types.cpp

mkdir -p /tmp/build
cd /tmp/build

cmake -DCMAKE_C_COMPILER=$(which clang-10) -DCMAKE_CXX_COMPILER=$(which clang++-10) -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra" -DLLVM_USE_LINKER=$(which gold) -DCMAKE_CROSSCOMPILING=True -DLLVM_TARGET_ARCH=AArch64 -DLLVM_DEFAULT_TARGET_TRIPLE=aarch64-linux-gnueabihf -DLLVM_TARGETS_TO_BUILD=AArch64 -DCMAKE_CXX_FLAGS='-march=armv8-a -mtune=cortex-a72' -Wno-dev -GNinja -DLLVM_TABLEGEN=/tmp/$llvm/build-host/bin/llvm-tblgen -DCLANG_TABLEGEN=/tmp/$llvm/build-host/bin/clang-tblgen -DLLVM_BUILD_LLVM_DYLIB=On -DLLVM_LINK_LLVM_DYLIB=On -DLLVM_INSTALL_TOOLCHAIN_ONLY=On /tmp/$llvm/llvm

ninja clangd
rm -rf /tmp/$llvm

mkdir -p /tmp/data/build/bin
mkdir -p /tmp/data/lib/clang
mv /tmp/build/bin/clangd /tmp/data/build/bin
mv /tmp/build/lib/clang/* /tmp/data/lib/clang
cd /tmp/data
curl -so LICENSE.txt https://raw.githubusercontent.com/Kapral67/Cling-Clangd/19fad1da46dbb76baa9a46ceb4971e92c2d9ee46/LICENSE
tar -zcf ./xeus-clangd.$version.$(uname -m).tar.gz *
rm -rf /tmp/build

mkdir -p /data/out
mv /tmp/data/xeus-clangd.$version.$(uname -m).tar.gz /data/out
