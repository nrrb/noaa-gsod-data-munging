#!/bin/bash
for year in {1929..2014}; do
    echo Stacking CSV files from $year
    csvstack $year/*.csv > $year.csv
done
