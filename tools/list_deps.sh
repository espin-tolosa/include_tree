#!/bin/bash

CURRENT=$(make current)
CURRENT_E=$(make current_e)
BIN=$(make current_bin)

find "$CURRENT_E" -iname "*.c" -exec cat {} \; | grep "\.h" | grep -oP '(?<=").*(?=")' | awk '!seen[$0]++'
readelf -d "$CURRENT/$BIN" | grep 'NEEDED' | grep -oP '(?<=\[).*(?=\])' | xargs whereis | awk '{print $2}'
