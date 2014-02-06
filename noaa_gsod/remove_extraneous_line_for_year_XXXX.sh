#!/bin/bash
year=$1
for filename in `ls $year/*.csv`; do
    # The extraneous line we're trying to get rid of can be distinguished
    # by the value of "F" in the "Fog" column. All data rows have numeric
    # values in that column.
    csvgrep -c "Fog" -i -m F $filename > $filename.cleaned
    mv $filename.cleaned $filename
done
