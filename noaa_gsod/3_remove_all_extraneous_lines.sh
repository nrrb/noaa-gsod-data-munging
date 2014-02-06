#!/bin/bash
for year in {1929..2014}; do
    echo Removing extraneous line from CSV files in $year
    ./3_remove_extraneous_line_for_year_XXXX.sh $year
done
