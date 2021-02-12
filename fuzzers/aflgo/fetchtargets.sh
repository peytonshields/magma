#!/bin/bash
# Output-> BBTargets.txt
set -e

source $TARGET/configrc
PATCH="${PATCHES}.patch" #TODO: if PATCHES include more than one patch, it will fail. Fix later

if [[ "$TARGET" == *"sqlite3"* ]]; then #TODO: add other benchmarks that have the same issue

        echo "Fetching BB targets manually"
        cp $FUZZER/targets/${PATCHES}  $OUT/BBtargets.txt
        exit
fi

echo "Fetching BB targets automatically"
cd $TARGET/patches/bugs
mkdir temp
cp $PATCH temp/.
cd temp

#divide patch into subpatches where each subpatch targets a different file
mkdir subpatches
cd subpatches
splitpatch --hunks ../$PATCH
cd ../

grep 'patching file\|Hunk' /tmp/patchlog.txt > patchlog.txt

#iterate over files in subpatch

FILES=$PWD/subpatches/*
for f in $FILES
do
  echo "Processing $f file..."
  line=$(head -n 1 $f)
  echo $line
#  func_name=$(cut -d "/" -f2 <<< "$line" | awk '{ print $1}')
  func_name=$(echo $line | awk -F "/" '{print $NF}')
  echo $func_name
  hunk_no=$(basename -- $f | cut -d "." -f 3)
  hunk_no=$(echo $hunk_no | sed 's/^0*//')
  hunk_no=$((hunk_no+1))
  echo $hunk_no
  grep -A $hunk_no $func_name patchlog.txt > tmpfile
  tail -1 tmpfile > tmpfile2
  start_line=$(awk '{for (I=1;I<NF;I++) if ($I == "at") print $(I+1)}' tmpfile2)
  echo $start_line
  awk '/^@@/' $f > hi
  awk '{ print $3}'  hi > hi2
  sed 's/^.//' hi2 > hi3
  while read p; do
        echo "$p" > current.txt
        total_linenum=($(awk -F',' '{print $2}' current.txt))
        end_line=$((start_line+total_linenum))

        for (( c=$start_line; c<=$end_line; c++ ))
        do
          echo "$func_name:$c" >> BBtargets.txt
        done
        cat hi
        func=$(cat hi | cut -f1 -d"(")
        echo $func
        func=$( echo $func | awk '{print $NF}')
        func=$( echo "${func//\*}" ) #if func name contains start i.e. pointer type; remove
        echo $func >> Ftargets.txt
  done <hi3
done

mv BBtargets.txt $OUT
mv Ftargets.txt $OUT
cd ../
rm -rf temp

