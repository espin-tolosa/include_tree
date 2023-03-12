#!/bin/bash

if (($# < 1))
then
  echo "Use: ./create_pair_files <file_name> (without extension)"
elif (($# > 1))
then
  echo "Use: ./create_pair_files <file_name> (without extension)"
fi

file=$1

whoami=$(whoami)
date=$(date)

inc="inc/$file.h"
src="src/$file.c"

touch "$inc"
touch "$src"

echo "/*File: $file.h, created by $whoami at $date */" >> "$inc"
echo "#ifndef ${file^^}_H" >> "$inc"
echo "#define ${file^^}_H" >> "$inc"

echo "" >> "$inc"
echo "" >> "$inc"
echo "" >> "$inc"

echo "#endif /* ${file^^}_H */" >> "$inc"


echo "/*File: $file.c, created by $whoami at $date */" >> "$src"
echo "#include \"$file.h\"" >> "$src"
