#!/bin/bash
for year in {1929..2014}; do
    echo Converting files for $year
    ./convert_op_to_csv_for_year_XXXX.sh $year
done
