#!/bin/bash
for year in {1929..2014}; do
    echo Stacking CSV files from $year
    ./4_stack_csv_for_year_XXXX.sh $year
done
