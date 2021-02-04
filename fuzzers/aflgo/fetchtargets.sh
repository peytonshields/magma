#!/bin/bash
# Output-> BBTargets.txt
set -e

source $TARGET/configrc
PATCH="${PATCHES}.patch" #TODO: if PATCHES include more than one patch, it will fail. Fix later

cd $TARGET/patches/bugs
mkdir temp
cp $PATCH temp/.
cd temp

#divide patch into subpatches where each subpatch targets a different file
mkdir subpatches
cd subpatches
splitpatch ../$PATCH
cd ../

#iterate over files in subpatch

FILES=$PWD/subpatches/*
for f in $FILES
do
  #echo "Processing $f file..."
  line=$(head -n 1 $f)
#  func_name=$(cut -d "/" -f2 <<< "$line" | awk '{ print $1}')
  func_name=$(echo $line | awk -F "/" '{print $NF}')
  awk '/^@@/' $f > hi
  awk '{ print $3}'  hi > hi2
  sed 's/^.//' hi2 > hi3
  while read p; do
        echo "$p" > current.txt
	start_line=($(awk -F',' '{print $1}' current.txt))
        total_linenum=($(awk -F',' '{print $2}' current.txt))
        end_line=$((start_line+total_linenum))

	for (( c=$start_line; c<=$end_line; c++ ))
        do
          echo "$func_name:$c" >> BBtargets.txt
        done

	func=$(cat hi  | awk '{print $NF}')
        func=$(echo $func | cut -f1 -d"(")
        echo $func >> Ftargets.txt

  done <hi3   
done

mv BBtargets.txt $OUT
mv Ftargets.txt $OUT
cd ../
rm -rf temp

