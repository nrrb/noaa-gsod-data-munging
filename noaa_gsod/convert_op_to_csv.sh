#!/bin/bash
for year in {1929..2014}; do
    echo Converting .op files in ./$year to CSV
    for filename in `ls $year/*.op`; do
        in2csv -s gsod_schema.csv $filename > $filename.csv
        # With the CSV now, we have no reason to keep the stinky .OP around
        if [ -f $filename.csv ]; then
            rm $filename
        fi
    done
done
