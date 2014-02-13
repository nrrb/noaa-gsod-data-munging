Background
==========

The NOAA has an [FTP site][1] where they provide Global Summary Of the Day (GSOD) measurements for nationwide weather stations dating back to 1929. There is a subfolder for each year, and within each year you can download a single file that contains all measurements for all stations of that year. For example, data for 1929 is found in [this directory][4], and all 1929 data can be downloaded with this single file:

[ftp://ftp.ncdc.noaa.gov/pub/data/gsod/1929/gsod_1929.tar][5]

The good thing is that they provide all the datas, the bad thing is that it's in a particular format described in [a text document here][2]. As well, the weather stations are referred to by unique GSOD ID in the data files, which is defined in [this 3MB ish-history.csv file][3]. There are 31940 weather stations listed in that file, each with a different start and end date of when it recorded measurements.

Prerequisites
=============

I developed this on a system running Ubuntu 12.04.3 x64.

* wget
* bash
* [csvkit][10]
* tar
* gunzip

On Ubuntu 12.04.3 x64, it comes by default with wget, bash, tar, and gunzip.

I install [csvkit][10] using a Python [virtualenv][11]. On a blank Ubuntu system, this is what I do:

```bash
sudo apt-get install python-setuptools
sudo easy_install pip
sudo pip install virtualenv virtualenvwrapper
source /usr/local/bin/virtualenvwrapper.sh
mkvirtualenv snowfall
pip install csvkit
```

If [virtualenv][11] sounds too complicated, you can install csvkit at the system level:

```
sudo apt-get install python-setuptools
sudo easy_install pip
sudo pip install csvkit
```


Getting Started
===============


Clone this repository and change directory into the `noaa_gsod` subfolder:

```
git clone https://github.com/tothebeat/chicago-snowfall.git
cd chicago-snowfall/noaa_gsod
```

This folder contains some shell scripts to help with downloading the data files from the NOAA FTP site.

## Download and Extract Data

Download all of the data with the [get_all_data.sh][7] script:

```bash
#!/bin/bash

# Although there are folders for years 1901 to 1928 on the FTP site, the archive files there are empty.
for year in {1929..2014}; do
    ./get_data_for_year_XXXX.sh $year
done
```

This script runs through the years 1929 to 2014 and runs [get_data_for_year_XXXX.sh][6] for each of them. 

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
for year in {1929..2012}; do
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
for year in {1929..2012}; do
    in2csv -s gsod_schema.csv $year.op > $year.csv
    rm $year.op
done
```


  [1]: ftp://ftp.ncdc.noaa.gov/pub/data/gsod/
  [2]: ftp://ftp.ncdc.noaa.gov/pub/data/gsod/GSOD_DESC.txt
  [3]: ftp://ftp.ncdc.noaa.gov/pub/data/gsod/ish-history.csv
  [4]: ftp://ftp.ncdc.noaa.gov/pub/data/gsod/1929/
  [5]: ftp://ftp.ncdc.noaa.gov/pub/data/gsod/1929/gsod_1929.tar
  [6]: https://github.com/tothebeat/noaa-gsod-data-munging/blob/master/noaa_gsod/get_data_for_year_XXXX.sh
  [7]: https://github.com/tothebeat/noaa-gsod-data-munging/blob/master/noaa_gsod/get_all_data.sh
  [8]: https://github.com/tothebeat/ffs/blob/master/us/noaa/gsod_schema.csv
  [9]: http://csvkit.readthedocs.org/en/latest/scripts/in2csv.html
  [10]: https://github.com/onyxfish/csvkit
  [11]: http://www.virtualenv.org/en/latest/
  [12]: https://github.com/tothebeat/noaa-gsod-data-munging/blob/master/noaa_gsod/strip_header_and_stack_op_files_for_year_XXXX.sh
