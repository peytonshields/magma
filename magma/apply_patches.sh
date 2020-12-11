#!/bin/bash
set -e

##
# Pre-requirements:
# - env TARGET: path to target work dir
##

# TODO filter patches by target config.yaml
source $TARGET/configrc

# TODO filter patches by target config.yaml
find "$TARGET/patches/setup" -name "*.patch" | \
while read patch; do
    echo "Applying $patch"
    patch -p1 -d "$TARGET/repo" <"$patch"
done

find "$TARGET/patches/bugs" -name "*.patch" | \
while read patch; do
        echo "Current patch: $patch"
        patchfile="$(basename -- $patch)"
        patch_name="${patchfile%.*}"
        echo "Applying $patch"

    if [[ $PATCHES == "all patches" ]]; then
        patch -p1 -d "$TARGET/repo" <"$patch"
    else
        if [[ "$PATCHES" == *"$patch_name"* ]]; then
          echo "Modifying $patch"
          sed -i 's/^.*+#ifdef MAGMA_ENABLE_CANARIES.*$/+#ifndef MAGMA_ENABLE_CANARIES/' "$patch"
          sed -i 's/^.*+#ifdef MAGMA_ENABLE_FIXES.*$/+#ifndef MAGMA_ENABLE_FIXES/' "$patch"
        fi
   #     patch -p1 -d "$TARGET/repo" <"$patch"
    fi
done
