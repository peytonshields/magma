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
    if [[ $PATCHES == "all patches" || "$PATCHES" == *"$patch_name"* ]]; then
        echo "Applying $patch"
        patch -p1 -d "$TARGET/repo" <"$patch"
    fi
done
