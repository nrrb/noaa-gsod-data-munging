chicago-snowfall
================

Getting a historical perspective on how much snow Chicago has been burdened by for every winter of recorded weather history.

Weather Data Source
===================

The NOAA has an [FTP site][1] where they provide Global Summary Of the Day (GSOD) measurements for nationwide weather stations dating back to 1929. There is a subfolder for each year, and within each year you can download a single file that contains all measurements for all stations of that year. For example, data for 1929 is found in [this directory][4], and all 1929 data can be downloaded with this single file:

[ftp://ftp.ncdc.noaa.gov/pub/data/gsod/1929/gsod_1929.tar][5]

The good thing is that they provide all the datas, the bad thing is that it's in a particular format described in [a text document here][2]. As well, the weather stations are referred to by unique GSOD ID in the data files, which is defined in [this 3MB ish-history.csv file][3]. There are 31940 weather stations listed in that file, each with a different start and end date of when it recorded measurements. 

Getting Started
===============

Clone this repository and change directory into the `noaa_gsod` subfolder:

```bash
git clone https://github.com/tothebeat/chicago-snowfall.git
cd chicago-snowfall/noaa_gsod
```

This folder contains some shell scripts to help with downloading the data files from the NOAA FTP site.

## [get_data_for_year_XXXX.sh][6]

To download and extract the data for 1959, you would run:

```bash
./get_data_for_year_XXXX.sh 1959
```

This script:

1. Creates a `1959` subfolder.
2. Downloads `ftp://ftp.ncdc.noaa.gov/pub/data/gsod/1959/gsod_1959.tar` to the new folder.
3. Extracts the contents into the same folder. The contents will be a set of gzipped files, each containing a year's worth of data for a single weather station.
4. Expands all of the gzipped files into raw `.op` data files.

```bash
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
```

## [convert_op_to_csv_for_year_XXXX.sh][7]

To convert the `.op` files you just downloaded for 1959 into CSV format, run:

```bash
./convert_op_to_csv_for_year_XXXX.sh 1959
```

This uses the excellent [in2csv][9] utility that's part of [onyxfish/csvkit][10], in conjunction with [a schema file][8] I forked from onyxfish/ffs.

```bash
#!/bin/bash
year=$1
for filename in `ls $year/*.op`; do
in2csv -s gsod_schema.csv $filename > $filename.csv
    # With the CSV now, we have no reason to keep the stinky .OP around
    if [ -f $filename.csv ]; then
rm $filename
    fi
done
```

The original file isn't well formatted to be a CSV, as there is a second header row that doesn't add any information to the first header row. 




  [1]: ftp://ftp.ncdc.noaa.gov/pub/data/gsod/
  [2]: ftp://ftp.ncdc.noaa.gov/pub/data/gsod/GSOD_DESC.txt
  [3]: ftp://ftp.ncdc.noaa.gov/pub/data/gsod/ish-history.csv
  [4]: ftp://ftp.ncdc.noaa.gov/pub/data/gsod/1929/
  [5]: ftp://ftp.ncdc.noaa.gov/pub/data/gsod/1929/gsod_1929.tar
  [6]: https://github.com/tothebeat/chicago-snowfall/blob/master/noaa_gsod/get_data_for_year_XXXX.sh
  [7]: https://github.com/tothebeat/chicago-snowfall/blob/master/noaa_gsod/convert_op_to_csv_for_year_XXXX.sh
  [8]: https://github.com/tothebeat/ffs/blob/master/us/noaa/gsod_schema.csv
  [9]: http://csvkit.readthedocs.org/en/latest/scripts/in2csv.html
  [10]: https://github.com/onyxfish/csvkit
