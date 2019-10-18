#!/bin/bash
year=$1
# Strip the first line of each of the .op files
find $year -name '*.op' -exec ./strip_header.sh {} \;
# Stack the .op files
find $year -name '*.op.header_stripped' -exec cat {} >> $year.op \;
