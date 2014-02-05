#!/bin/bash

# Create a directory for the year

year=$1
if [ ! -d "$year" ]; then
    echo "Creating a directory."
    mkdir -p $year
fi

# Download the data
wget ftp://ftp.ncdc.noaa.gov/pub/data/gsod/$year/gsod_$year.tar -O $year/gsod_$year.tar

# Unzip the data
if [ -f "$year/gsod_$year.tar" ]; then
    echo "Unzipping the downloaded data."
    tar -xvf $year/gsod_$year.tar -C $year/
fi
