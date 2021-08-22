#!/bin/bash

apt update && DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends git build-essential subversion python3-dev python3-pip libncurses5-dev libxml2-dev libedit-dev swig graphviz xz-utils ninja-build gcc g++ sed sudo wget

yes | pip3 install --upgrade cmake

export C=/usr/bin/gcc
export CXX=/usr/bin/g++
cd /tmp
git clone --branch llvmorg-12.0.1 https://github.com/llvm/llvm-project.git

# Edit for Clangd to work with Jupyter .ipynb
sed -i "265i\\\t   .Case(\"ipynb\", TY_CXX)" /tmp/llvm-project/clang/lib/Driver/Types.cpp

mkdir -p /tmp/build
cd /tmp/build
cmake /tmp/llvm-project/llvm -G Ninja -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra"
ninja clangd
rm -rf /tmp/llvm-project

mkdir -p /tmp/data/build/bin
mkdir -p /tmp/data/lib/clang
mv /tmp/build/bin/clangd /tmp/data/build/bin
mv /tmp/build/lib/clang/* /tmp/data/lib/clang
cd /tmp/data
wget -O LICENSE.txt https://raw.githubusercontent.com/Kapral67/Cling-Clangd/19fad1da46dbb76baa9a46ceb4971e92c2d9ee46/LICENSE
tar -zcf ./jupyter-clangd.$(uname -m).tar.gz *
rm -rf /tmp/build

mkdir -p /data/out
mv /tmp/data/jupyter-clangd.$(uname -m).tar.gz /data/out
