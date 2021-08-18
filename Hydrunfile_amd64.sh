#!/bin/bash

apt update
apt install -y git build-essential subversion python3-dev python3-pip libncurses5-dev libxml2-dev libedit-dev swig graphviz xz-utils ninja-build gcc g++ sed sudo

yes | pip3 install --upgrade cmake

export C=/usr/bin/gcc
export CXX=/usr/bin/g++
cd /tmp
git clone --branch llvmorg-12.0.1 https://github.com/llvm/llvm-project.git

# Edit for Clangd to work with Jupyter .ipynb
sed -i "265i\\\t   .Case(\"ipynb\", TY_CXX)" /tmp/llvm-project/clang/lib/Driver/Types.cpp

mkdir -p /out/build
cd /out/build
cmake /tmp/llvm-project/llvm -G Ninja -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra"
ninja clangd
rm -rf /tmp/llvm-project

mkdir -p /out/data/build/bin
mkdir -p /out/data/lib/clang
mv /out/build/bin/clangd /out/data/build/bin
mv /out/build/lib/clang/* /out/data/lib/clang
cd /out/data
tar -zcf ./jupyter-clangd.$(uname -m).tar.gz *
rm -rf /out/build

mkdir -p /data/out
mv /out/data/jupyter-clangd.$(uname -m).tar.gz /data/out
