from ftplib import FTP
import os

ftp = FTP('ftp.ncdc.noaa.gov', user='anonymous')

all_filenames = []
for year in range(1901, 2015):
    path = '/pub/data/gsod/{y}'.format(y=year)
    ftp.cwd(path)
    filenames = [os.path.join(path, fn) for fn in ftp.nlst()
                    if '.op.gz' in fn]
    print 'Found {n} files for year {y}.'.format(
            n=len(filenames), y=year)
    all_filenames += filenames
with open('all_ftp_files.txt', 'wb') as f:
    f.writelines([filename + '\n' for filename in all_filenames])
