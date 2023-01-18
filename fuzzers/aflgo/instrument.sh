#!/bin/bash
#set -e

##
# Pre-requirements:
# - env FUZZER: path to fuzzer work dir
# - env TARGET: path to target work dir
# - env MAGMA: path to Magma support files
# - env OUT: path to directory where artifacts are stored
# - env CFLAGS and CXXFLAGS must be set to link against Magma instrumentation
##
COPY_CFLAGS=$CFLAGS
COPY_CXXFLAGS=$CXXFLAGS
mkdir $TARGET/repo/temp
#BUILD_FOLD=$FUZZER/repo/llvm/build
BUILD_FOLD=$FUZZER/llvm/build
export PATH="$BUILD_FOLD/llvm_tools/build-llvm/llvm/build/bin:$PATH"
export LD_LIBRARY_PATH="$BUILD_FOLD/llvm_tools/build-llvm/llvm/build/lib/:$FUZZER/repo/bin/lib:$LD_LIBRARY_PATH"

export CC="$FUZZER/repo/afl-clang-fast"
export CXX="$FUZZER/repo/afl-clang-fast++"
export TMP_DIR=$TARGET/repo/temp

# Set targets for specified bugs 
(
      echo "Setting targets"
      $FUZZER/fetchtargets.sh

	  echo "Fetched BBtargets: "
	  cat "$TMP_DIR/BBtargets.txt"

	  #echo "Downloading original BBtargets"
	  #wget https://raw.githubusercontent.com/scanakci/magma/aflgo/fuzzers/aflgo/targets/AAH010 -O "$TMP_DIR/BBtargets.txt"
	  #cat "$TMP_DIR/BBtargets.txt"
)

# Generate CG and intra-procedural CFGs from program
(
    echo "Generating CG"
    source "$TARGET/configrc"
    export LDFLAGS="$LDFLAGS -L$OUT"
    export LIBS="$LIBS -l:afl_driver.o -lstdc++"

    "$MAGMA/build.sh"

    export ADDITIONAL="-targets=$TMP_DIR/BBtargets.txt -outdir=$TMP_DIR -flto -fuse-ld=gold -Wl,-plugin-opt=save-temps"
    export CFLAGS="$COPY_CFLAGS $ADDITIONAL"
    export CXXFLAGS="$COPY_CXXFLAGS $ADDITIONAL"
    "$TARGET/build.sh"

	echo "Exported Distances: "
	cat "$TMP_DIR/callgraph.distance.txt"

 #   if [[ "$TARGET" == *"sqlite3"* ]]; then #TODO: add other benchmarks that have the same issue
 #     echo "Second time compilation due to a potential bug in clang 4.0."
 #     export ADDITIONAL="-targets=$TMP_DIR/BBtargets.txt -outdir=$TMP_DIR -flto -fuse-ld=gold -v" 
 #     export CFLAGS="$COPY_CFLAGS $ADDITIONAL"
 #     export CXXFLAGS="$COPY_CXXFLAGS $ADDITIONAL"
 #     "$TARGET/build.sh"
 #   fi

    echo "target build is done"   
	cat $TMP_DIR/BBnames.txt | grep -v "^$"| rev | cut -d: -f2- | rev | sort | uniq > $TMP_DIR/BBnames2.txt && mv $TMP_DIR/BBnames2.txt $TMP_DIR/BBnames.txt
	cat $TMP_DIR/BBcalls.txt | grep -Ev "^[^,]*$|^([^,]*,){2,}[^,]*$"| sort | uniq > $TMP_DIR/BBcalls2.txt && mv $TMP_DIR/BBcalls2.txt $TMP_DIR/BBcalls.txt

    cd "$TARGET/repo"
    echo "Generating distance for $AFLGO_PROGRAM"
	$FUZZER/repo/scripts/gen_distance_fast.py $TARGET/repo $TMP_DIR $AFLGO_PROGRAM
	#$FUZZER/repo/scripts/genDistance.sh $TARGET/repo/tools $TMP_DIR "tiffcp"
)


# Instrument the program
(
    echo "Instrumenting the program"
    cd "$TARGET/repo"

    export CFLAGS="$COPY_CFLAGS -distance=$TMP_DIR/distance.cfg.txt"
    export CXXFLAGS="$COPY_CXXFLAGS -distance=$TMP_DIR/distance.cfg.txt"

    export LDFLAGS="$LDFLAGS -L$OUT -L$FUZZER/repo/bin/lib"
    export LIBS="$LIBS -l:afl_driver.o -lstdc++"

    "$TARGET/build.sh"
)

# NOTE: We pass $OUT directly to the target build.sh script, since the artifact
#       itself is the fuzz target. In the case of Angora, we might need to
#       replace $OUT by $OUT/fast and $OUT/track, for instance.
