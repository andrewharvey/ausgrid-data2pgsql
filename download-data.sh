#!/bin/sh

download_prefix=data

mkdir -p "$download_prefix/works"

# scrape this URL for CSV data downloads and download them
wget -O - 'http://www.ausgrid.com.au/Common/About-us/Sharing-information/Data-to-share.aspx' | \
  grep -o 'href="/RemoteDataService[^"]*' | \
  sed 's/^href="/http:\/\/www.ausgrid.com.au/' | \
  wget --directory-prefix="$download_prefix/works" -i -

# rename downloaded files
cd "$download_prefix/works"
for f in RemoteDataService* ; do
  mv "$f" `echo "$f" | grep -o "QuarterName=.*" | sed 's/QuarterName=//' | tr ' ' '_' | sed 's/$/.csv/g'`
done
cd ../../

# also grab avg electricity usage by LGA
mkdir -p "$download_prefix/usage"
wget -O - 'http://www.ausgrid.com.au/Common/About-us/Sharing-information/Data-to-share/~/media/Files/About%20Us/Sharing%20Information/Average_electricity_consumption_by_LGA%20rev%206Apr11.ashx' | head --lines=-8 | tail --lines=+3 > "$download_prefix/usage/Average_electricity_consumption_by_LGA_2010.csv"
