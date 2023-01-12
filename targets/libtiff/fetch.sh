#!/bin/bash

##
# Pre-requirements:
# - env TARGET: path to target work dir
##

git clone --no-checkout https://gitlab.com/libtiff/libtiff.git \
    "$TARGET/repo"
<<<<<<< HEAD
git -C "$TARGET/repo" checkout 2e822691d750c01cec5b5cc4ee73567a204ab2a3
=======
git -C "$TARGET/repo" checkout c145a6c14978f73bb484c955eb9f84203efcb12e
>>>>>>> upstream/v1.2

cp "$TARGET/src/tiff_read_rgba_fuzzer.cc" \
    "$TARGET/repo/contrib/oss-fuzz/tiff_read_rgba_fuzzer.cc"
