#!/bin/bash

apt update && DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends build-essential subversion python3-dev python3-pip libncurses5-dev libxml2-dev libedit-dev xz-utils ninja-build gcc g++ sed curl wget

yes | pip3 install --upgrade cmake

export C=/usr/bin/gcc
export CXX=/usr/bin/g++
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
cmake /tmp/$llvm/llvm -G Ninja -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra"
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
