#!/bin/bash
for year in {1929..2017}
do
    echo $year
    wc --lines $year/*.op | head --lines=-1 | sed 's/[ \t]*//' | cut --delimiter=" " --fields=1 | ./summary.r
done

