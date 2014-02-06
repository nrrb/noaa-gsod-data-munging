chicago-snowfall
================

Getting a historical perspective on how much snow Chicago has been burdened by for every winter of recorded weather history.

Weather Data Source
===================

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

If you just want to get started super quickly, cross your fingers, and read the instructions later:

```
./1_get_all_data.sh && ./2_convert_all_op_to_csv.sh && ./3_remove_all_extraneous_lines.sh && 4_stack_all_csvs.sh
```

## [1_get_data_for_year_XXXX.sh][6]

To download and extract the data for 1929, you would run:

```
./1_get_data_for_year_XXXX.sh 1929
```

This script:

1. Creates a `1929` subfolder.
2. Downloads `ftp://ftp.ncdc.noaa.gov/pub/data/gsod/1929/gsod_1929.tar` to the new folder.
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
        gunzip $filename
    done
fi
```

## [2_convert_op_to_csv_for_year_XXXX.sh][7]

To convert the `.op` files you just downloaded for 1929 into CSV format, run:

```
./2_convert_op_to_csv_for_year_XXXX.sh 1929
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

## [3_remove_extraneous_line_for_year_XXXX.sh][12]

The original file isn't well formatted to be a CSV, as there is a second header row that doesn't add any information to the first header row.

To run on the CSV files we have from 1929:

```
./3_remove_extraneous_line_for_year_XXXX.sh 1929
```

To remove the extraneous line, I use [csvkit][10]'s excellent [csvgrep][14] script. I use the inverse-match argument for csvgrep to find all lines that **don't** match the extra header row. It's easy to pick out; in the "Fog" column, the extra row says "F" while real data rows will show "1" or "0".

```bash
#!/bin/bash
year=$1
for filename in `ls $year/*.csv`; do
    # The extraneous line we're trying to get rid of can be distinguished
    # by the value of "F" in the "Fog" column. All data rows have numeric
    # values in that column.
    csvgrep -c "Fog" -i -m F $filename > $filename.cleaned
    mv $filename.cleaned $filename
done
```

## [4_stack_csv_for_year_XXXX.sh][13]

Each year's folder now has a set of cleaned CSV files in it. All the information provided by the filename is also inside the CSV files themselves, so we can stack these together easily.

```
./4_stack_csv_for_year_XXXX.sh 1929
```

This script uses another tool from [csvkit][10] called [csvstack][15], that can join rows together from CSV files that have the same header row.

```bash
#!/bin/bash
csvstack $1/*.csv > $1.csv
# If the stack was created, delete the original individual CSV files
if [ -f $1.csv ]; then
rm -rf $1/
fi
```


  [1]: ftp://ftp.ncdc.noaa.gov/pub/data/gsod/
  [2]: ftp://ftp.ncdc.noaa.gov/pub/data/gsod/GSOD_DESC.txt
  [3]: ftp://ftp.ncdc.noaa.gov/pub/data/gsod/ish-history.csv
  [4]: ftp://ftp.ncdc.noaa.gov/pub/data/gsod/1929/
  [5]: ftp://ftp.ncdc.noaa.gov/pub/data/gsod/1929/gsod_1929.tar
  [6]: https://github.com/tothebeat/chicago-snowfall/blob/master/noaa_gsod/1_get_data_for_year_XXXX.sh
  [7]: https://github.com/tothebeat/chicago-snowfall/blob/master/noaa_gsod/2_convert_op_to_csv_for_year_XXXX.sh
  [8]: https://github.com/tothebeat/ffs/blob/master/us/noaa/gsod_schema.csv
  [9]: http://csvkit.readthedocs.org/en/latest/scripts/in2csv.html
  [10]: https://github.com/onyxfish/csvkit
  [11]: http://www.virtualenv.org/en/latest/
  [12]: https://github.com/tothebeat/chicago-snowfall/blob/master/noaa_gsod/3_remove_extraneous_line_for_year_XXXX.sh
  [13]: https://github.com/tothebeat/chicago-snowfall/blob/master/noaa_gsod/4_stack_csv_for_year_XXXX.sh
  [14]: http://csvkit.readthedocs.org/en/latest/scripts/csvgrep.html
  [15]: http://csvkit.readthedocs.org/en/latest/scripts/csvstack.html