#!/bin/bash

# Create a directory for the year

year=$1
if [ ! -d "$year" ]; then
    echo "Creating a directory."
    mkdir -p $year
fi

# Download the data (if we don't already have it)
if [ ! -f "$year/gsod_$year.tar" ]; then
    wget ftp://ftp.ncdc.noaa.gov/pub/data/gsod/$year/gsod_$year.tar -O $year/gsod_$year.tar
fi

# Unzip the data
if [ -f "$year/gsod_$year.tar" ]; then
    echo "Unzipping the downloaded data."
    tar -xvf $year/gsod_$year.tar -C $year/
    rm $year/gsod_$year.tar
    for filename in `ls $year/*.gz`; do
        gunzip $year/$filename
    done
fi
