#!/bin/bash
set -e

##
# Pre-requirements:
# - env FUZZER: path to fuzzer work dir
##

if [ ! -d "$FUZZER/repo" ]; then
    echo "fetch.sh must be executed first."
    exit 1
fi

ln -s /usr/include/locale.h /usr/include/xlocale.h

# Build LLVM
BUILD_FOLD=$FUZZER/repo/llvm/build
cd $BUILD_FOLD/llvm_tools/build-llvm/llvm

cmake -G "Ninja" \
	    -DLIBCXX_ENABLE_SHARED=OFF -DLIBCXX_ENABLE_STATIC_ABI_LIBRARY=ON \
		-DCMAKE_BUILD_TYPE=Release -DLLVM_TARGETS_TO_BUILD="X86" \
		-DLLVM_BINUTILS_INCDIR=/usr/include \
		-DCMAKE_INSTALL_PREFIX=$BUILD_FOLD/llvm_tools/build-llvm/llvm/build \
		$BUILD_FOLD/llvm_tools/llvm-11.0.0.src
ninja -j 6
ninja install

echo "Installed LLVM"

cd $BUILD_FOLD/llvm_tools
mkdir -p build-llvm/msan; cd build-llvm/msan

cmake -G "Ninja" \
      -DCMAKE_C_COMPILER=$BUILD_FOLD/llvm_tools/build-llvm/llvm/bin/clang \
	  -DCMAKE_CXX_COMPILER=$BUILD_FOLD/llvm_tools/build-llvm/llvm/bin/clang++ \
      -DLLVM_USE_SANITIZER=Memory \
      -DCMAKE_INSTALL_PREFIX=$BUILD_FOLD/llvm_tools/build-llvm/msan/build/ \
      -DLIBCXX_ENABLE_SHARED=OFF -DLIBCXX_ENABLE_STATIC_ABI_LIBRARY=ON \
      -DCMAKE_BUILD_TYPE=Release -DLLVM_TARGETS_TO_BUILD="X86" \
       $BUILD_FOLD/llvm_tools/llvm-11.0.0.src

ninja cxx
ninja install-cxx

echo "Installed LLVM-CXX"

#cmake -G "Ninja" \
#      -DLIBCXX_ENABLE_SHARED=OFF -DLIBCXX_ENABLE_STATIC_ABI_LIBRARY=ON \
#      -DCMAKE_BUILD_TYPE=Release -DLLVM_TARGETS_TO_BUILD="X86" \
#      -DLLVM_BINUTILS_INCDIR=/usr/include \
#      -DCMAKE_INSTALL_PREFIX=$BUILD_FOLD/llvm_tools/build-llvm/llvm/build \
#       $BUILD_FOLD/llvm_tools/llvm-4.0.0.src 
#ninja -j 6; 
#ninja install
#
#cd $BUILD_FOLD/llvm_tools
#mkdir -p build-llvm/msan; 
#cd build-llvm/msan
#cmake -G "Ninja" \
#      -DCMAKE_C_COMPILER=$BUILD_FOLD/llvm_tools/build-llvm/llvm/bin/clang -DCMAKE_CXX_COMPILER=$BUILD_FOLD/llvm_tools/build-llvm/llvm/bin/clang++ \
#      -DLLVM_USE_SANITIZER=Memory \
#      -DCMAKE_INSTALL_PREFIX=$BUILD_FOLD/llvm_tools/build-llvm/msan/build/ \
#      -DLIBCXX_ENABLE_SHARED=OFF -DLIBCXX_ENABLE_STATIC_ABI_LIBRARY=ON \
#      -DCMAKE_BUILD_TYPE=Release -DLLVM_TARGETS_TO_BUILD="X86" \
#       $BUILD_FOLD/llvm_tools/llvm-4.0.0.src
#ninja cxx; 
#ninja install-cxx

# Install LLVMgold in bfd-plugins
mkdir -p /usr/lib/bfd-plugins
cp $BUILD_FOLD/llvm_tools/build-llvm/llvm/build/lib/libLTO.so /usr/lib/bfd-plugins/.
cp $BUILD_FOLD/llvm_tools/build-llvm/llvm/build/lib//LLVMgold.so /usr/lib/bfd-plugins/

export LC_ALL=C

# Build AFLGo
export PATH="$BUILD_FOLD/llvm_tools/build-llvm/llvm/build/bin:$PATH"
cd "$FUZZER/repo"
CC=clang make clean all -j $(nproc)
CC=clang make clean all -j $(nproc) -C llvm_mode
pushd distance_calculator
	cmake -G Ninja ./
	cmake --build ./
popd

# compile afl_driver.cpp
"./afl-clang-fast++" $CXXFLAGS -std=c++11 -c "afl_driver.cpp" -fPIC -o "$OUT/afl_driver.o"
