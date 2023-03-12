#!/bin/bash

make all
CURRENT=$(make current)
CURRENT_E=$(make current_e)
BIN=$(make current_bin)

I=$(find "$CURRENT_E" -iname "*.c" -exec cat {} \; | grep "\.h" | grep -oP '(?<=").*(?=")' | awk '!seen[$0]++')
L=$(readelf -d "$CURRENT/$BIN" | grep 'NEEDED' | grep -oP '(?<=\[).*(?=\])' | xargs whereis | awk '{print $2}')

echo "$I" | grep -v "./inc/" | xargs -n 1 dirname | xargs -I {} mkdir -p ./include{}
echo "$L" | grep -v "./inc/" | xargs -n 1 dirname | xargs -I {} mkdir -p ./include{}

echo "$I" | grep -v "./inc/" | xargs -I {} cp {} ./include{}
echo "$L" | grep -v "./inc/" | xargs -I {} cp {} ./include{}

