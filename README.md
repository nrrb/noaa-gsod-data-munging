Background
==========

The National Oceanographic and Atmospheric Agency's (NOAA) National Climatic Data Center (NCDC) collects and distributes climate measurements from thousands of weather stations around the world, with some records dating back as early as 1929. The NCDC has an [FTP site][1] where they provide Global Summary Of the Day (GSOD) measurements, derived from hourly measurements found in the [Integrated Surfaces Database][13].

This repository wouldn't have to exist if it was easy to get and use all of the data, but it's not (or it wasn't for me). There's a fixed-width column format with its key/schema described [in this text file][2], the weather stations themselves are defined in [this 3MB CSV file][3] and related by unique ID, and the data is split up into many individual files per year and station.

All data collected for a given year can be found in a single TAR archive file, thankfully. For example, data collected in 1929 can be found here:

[ftp://ftp.ncdc.noaa.gov/pub/data/gsod/1929/gsod_1929.tar][5]

This TAR file, when extracted, contains 21 files, each of which contains the data collected from a single weather station. Each weather station may not have recorded data for every day of the year.

## Prerequisites

I did this download on an Ubuntu system, but it could be done equally well on a Mac or in a Bash shell on Windows, anywhere you can install [csvkit][10]. On Ubuntu, I installed csvkit using a [Python virtual environment][11], but you might find csvkit so useful that you install it globally.

```bash
sudo apt-get install python3-pip
virtualenv -p python3 ~/.venv
source ~/.venv/bin/activate
pip install csvkit
```

Any time you want to get back to using csvkit, you can run:

```bash
source ~/.venv/bin/activate
```

You can install csvkit at the system level:

```
sudo pip install csvkit
```

## Download and Extract Data

Download all of the data with the [get_all_data.sh][7] script:

```bash
#!/bin/bash

# Although there are folders for years 1901 to 1928 on the FTP site, the archive files there are empty.
for year in {1929..2017}; do
    ./get_data_for_year_XXXX.sh $year
done
```

This script runs through the years 1929 to 2017 and runs [get_data_for_year_XXXX.sh][6] for each of them.

Starting with year 1929, this script:

1. Creates a `1929` subfolder.
2. Downloads `ftp://ftp.ncdc.noaa.gov/pub/data/gsod/1929/gsod_1929.tar` to the new folder.
3. Extracts the contents into the same folder. The contents will be a set of gzipped files, each containing a year's worth of data for a single weather station.
4. Expands all of the gzipped files into raw `.op` data files.

```bash
#!/bin/bash
year=$1

# Create a directory for the year
if [ ! -d "$year" ]; then
echo Creating a directory.
    mkdir -p $year
fi

# Download the data (if we don't already have it)
if [ ! -f "$year/gsod_$year.tar" ]; then
wget ftp://ftp.ncdc.noaa.gov/pub/data/gsod/$year/gsod_$year.tar -O $year/gsod_$year.tar
fi

# Unzip the data
if [ -f "$year/gsod_$year.tar" ]; then
echo Unzipping the downloaded data.
    tar -xvf $year/gsod_$year.tar -C $year/
    rm $year/gsod_$year.tar
    for filename in `ls $year/*.gz`; do
        gunzip $filename
    done
fi
```

In each year's folder, we now have a number of `.op` files each representing a single weather station's data for the year, and that number increases drastically over the years. For instance, 1929 has 21 station data files while 2013 has 12510 station data files.

## Stack Data Files into One per Year

With each data file containing 366 data rows at most, and there being a large number of data files for many of the years, the computational overhead of opening and processing files one by one becomes notable. Since the format of all of the `.op` files is the same, we can safely concatenate/stack them into a single file for each of the years, to later be processed into a single CSV.

The trick is to remove the header row of each `.op` file first, so it doesn't appear incorrectly as data rows in the stacked file:

```bash
for filename in `ls 1929/*.op`; do
    tail -n +2 $filename > $filename.header_stripped
    mv $filename.header_stripped $filename
done
```

To stack the `.op` files for 1929, we can simply do:

```bash
cat 1929/*.op > 1929_stacked.op
```

I combined the two steps above into a single script that works on a year at a time, [strip_header_and_stack_op_files_for_year_XXXX.sh][12]. To run this against all files, do:

```bash
for year in {1929..2017}; do
    echo $year
    ./strip_header_and_stack_op_files_for_year_XXXX.sh $year
done
```

## Convert .op Files to CSV

To convert `1929.op` into a CSV file, we'll use the excellent [in2csv][9] utility that's part of [onyxfish/csvkit][10], in conjunction with [a schema file][8] I forked from onyxfish/ffs:

```
in2csv -s gsod_schema.csv 1929.op > 1929.csv
rm 1929.op
```

To convert all stacked .op files into CSV:

```bash
for year in {1929..2017}; do
    in2csv -s gsod_schema.csv $year.op > $year.csv
    rm $year.op
done
```


  [1]: ftp://ftp.ncdc.noaa.gov/pub/data/gsod/
  [2]: ftp://ftp.ncdc.noaa.gov/pub/data/gsod/GSOD_DESC.txt
  [3]: ftp://ftp.ncdc.noaa.gov/pub/data/gsod/ish-history.csv
  [4]: ftp://ftp.ncdc.noaa.gov/pub/data/gsod/1929/
  [5]: ftp://ftp.ncdc.noaa.gov/pub/data/gsod/1929/gsod_1929.tar
  [6]: https://github.com/tothebeat/noaa-gsod-data-munging/blob/master/get_data_for_year_XXXX.sh
  [7]: https://github.com/tothebeat/noaa-gsod-data-munging/blob/master/get_all_data.sh
  [8]: https://github.com/tothebeat/ffs/blob/master/us/noaa/gsod_schema.csv
  [9]: http://csvkit.readthedocs.org/en/latest/scripts/in2csv.html
  [10]: https://github.com/onyxfish/csvkit
  [11]: http://www.virtualenv.org/en/latest/
  [12]: https://github.com/tothebeat/noaa-gsod-data-munging/blob/master/strip_header_and_stack_op_files_for_year_XXXX.sh
  [13]: https://www.ncdc.noaa.gov/isd
