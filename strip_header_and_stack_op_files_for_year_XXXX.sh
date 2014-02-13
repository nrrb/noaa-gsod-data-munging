#!/bin/bash
year=$1
# Strip the first line of each of the .op files
for filename in `ls $year/*.op`; do
    tail -n +2 $filename > $filename.header_stripped
    mv $filename.header_stripped $filename
done
# Stack the .op files
cat $year/*.op > $year.op
