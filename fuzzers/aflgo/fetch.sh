#!/bin/bash
set -e

##
# Pre-requirements:
# - env FUZZER: path to fuzzer work dir
##

#git clone --no-checkout https://github.com/aflgo/aflgo.git "$FUZZER/repo"
git clone https://github.com/aflgo/aflgo.git "$FUZZER/repo"

# Patch issue in AFLGo that causes it to fail to compile .S files
cp $FUZZER/patches/afl-clang-fast.c $FUZZER/repo/llvm_mode

#git -C "$FUZZER/repo" checkout e27a9084fba30a6623255b4856b67df514e32f69
#wget -O "$FUZZER/repo/afl_driver.cpp" \
#    "https://cs.chromium.org/codesearch/f/chromium/src/third_party/libFuzzer/src/afl/afl_driver.cpp"
cp "$FUZZER/src/afl_driver.cpp" "$FUZZER/repo/afl_driver.cpp"

#Install LLVM
BUILD_FOLD=$FUZZER/repo/llvm/build
mkdir -p $BUILD_FOLD
cd $BUILD_FOLD
mkdir llvm_tools; cd llvm_tools

wget https://github.com/llvm/llvm-project/releases/download/llvmorg-11.0.0/llvm-11.0.0.src.tar.xz
wget https://github.com/llvm/llvm-project/releases/download/llvmorg-11.0.0/clang-11.0.0.src.tar.xz
wget https://github.com/llvm/llvm-project/releases/download/llvmorg-11.0.0/compiler-rt-11.0.0.src.tar.xz
wget https://github.com/llvm/llvm-project/releases/download/llvmorg-11.0.0/libcxx-11.0.0.src.tar.xz
wget https://github.com/llvm/llvm-project/releases/download/llvmorg-11.0.0/libcxxabi-11.0.0.src.tar.xz

#wget http://releases.llvm.org/4.0.0/llvm-4.0.0.src.tar.xz
#wget http://releases.llvm.org/4.0.0/cfe-4.0.0.src.tar.xz
#wget http://releases.llvm.org/4.0.0/compiler-rt-4.0.0.src.tar.xz
#wget http://releases.llvm.org/4.0.0/libcxx-4.0.0.src.tar.xz
#wget http://releases.llvm.org/4.0.0/libcxxabi-4.0.0.src.tar.xz

tar xf llvm-11.0.0.src.tar.xz
tar xf clang-11.0.0.src.tar.xz
tar xf compiler-rt-11.0.0.src.tar.xz
tar xf libcxx-11.0.0.src.tar.xz
tar xf libcxxabi-11.0.0.src.tar.xz

#tar xf llvm-4.0.0.src.tar.xz
#tar xf cfe-4.0.0.src.tar.xz
#tar xf compiler-rt-4.0.0.src.tar.xz
#tar xf libcxx-4.0.0.src.tar.xz
#tar xf libcxxabi-4.0.0.src.tar.xz

mv clang-11.0.0.src $BUILD_FOLD/llvm_tools/llvm-11.0.0.src/tools/clang
mv compiler-rt-11.0.0.src $BUILD_FOLD/llvm_tools/llvm-11.0.0.src/projects/compiler-rt
mv libcxx-11.0.0.src $BUILD_FOLD/llvm_tools/llvm-11.0.0.src/projects/libcxx
mv libcxxabi-11.0.0.src $BUILD_FOLD/llvm_tools/llvm-11.0.0.src/projects/libcxxabi

#mv cfe-4.0.0.src $BUILD_FOLD/llvm_tools/llvm-4.0.0.src/tools/clang
#mv compiler-rt-4.0.0.src $BUILD_FOLD/llvm_tools/llvm-4.0.0.src/projects/compiler-rt
#mv libcxx-4.0.0.src $BUILD_FOLD/llvm_tools/llvm-4.0.0.src/projects/libcxx
#mv libcxxabi-4.0.0.src $BUILD_FOLD/llvm_tools/llvm-4.0.0.src/projects/libcxxabi

# Patch missing include in llvm-11.0.0
cp $FUZZER/patches/benchmark_register.h $BUILD_FOLD/llvm_tools/llvm-11.0.0.src/utils/benchmark/src/

# Prep build dir for next stage
mkdir -p build-llvm/llvm; cd build-llvm/llvm
