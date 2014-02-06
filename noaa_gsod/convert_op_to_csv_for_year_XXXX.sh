#!/bin/bash
year=$1
for filename in `ls $year/*.op`; do
    in2csv -s gsod_schema.csv $filename > $filename.csv
    # With the CSV now, we have no reason to keep the stinky .OP around
    if [ -f $filename.csv ]; then
        rm $filename
    fi
done
