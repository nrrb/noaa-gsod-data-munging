#!/bin/bash

# Get the measurement station list, which is keyed by STN and WBAN numbers in the data files
./get_station_list.sh
# Although there are folders for years 1901 to 1928 on the FTP site, the archive files there are empty.
for year in {1929..2019}; do
    ./get_data_for_year_XXXX.sh $year
done
