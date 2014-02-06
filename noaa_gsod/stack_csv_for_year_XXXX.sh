#!/bin/bash
csvstack $1/*.csv > $1.csv
# If the stack was created, delete the original individual CSV files
if [ -f $1.csv ]; then
    rm -rf $1/
fi
