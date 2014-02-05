chicago-snowfall
================

Getting a historical perspective on how much snow Chicago has been burdened by for every winter of recorded weather history.

Getting The Data
================

The NOAA has an [FTP site][1] where they provide Global Summary Of the Day (GSOD) measurements for nationwide weather stations dating back to 1929. There is a subfolder for each year, and within each year you can download a single file that contains all measurements for all stations of that year. For example, data for 1929 is found in [this directory][4], and all 1901 data can be downloaded with this single file:

[ftp://ftp.ncdc.noaa.gov/pub/data/gsod/1929/gsod_1929.tar][5]

The good thing is that they provide all the datas, the bad thing is that it's in a particular format described in [a text document here][2]. As well, the weather stations are referred to by unique GSOD ID in the data files, which is defined in [this 3MB ish-history.csv file][3]. There are 31940 weather stations listed in that file, each with a different start and end date of when it recorded measurements. 


  [1]: ftp://ftp.ncdc.noaa.gov/pub/data/gsod/
  [2]: ftp://ftp.ncdc.noaa.gov/pub/data/gsod/GSOD_DESC.txt
  [3]: ftp://ftp.ncdc.noaa.gov/pub/data/gsod/ish-history.csv
  [4]: ftp://ftp.ncdc.noaa.gov/pub/data/gsod/1929/
  [5]: ftp://ftp.ncdc.noaa.gov/pub/data/gsod/1929/gsod_1929.tar
