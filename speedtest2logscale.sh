#!/bin/sh

# Script by bjorn.graabek@crowdstrike.com
# This script uses Speedtest CLI to run tests and sends the results to a LogScale or Falcon NG-SIEM instance using HEC.
# Speedtest CLI can be downloaded here: https://www.speedtest.net/apps/cli
# Download and install speedtest cli + get the LogScale/Falcon NG-SIEM ingest url and token before running the script
# Configure cron to run the script as regularly as you want.

# There are two sections to the script.
# First section will only test against servers defined in a config file.
# Second section will test against servers deemed to be close to you. In my limited testing and where I live, four different servers were chosen at different times.
# You could run the script and exclusively test against servers defined by you, you could exclusively test against servers chosen by speedtest.net.
# Or you can do both.

# List of speedtest servers, not all server ID's on this list work.
# There are others available on the internet...
# https://gist.github.com/ofou/654efe67e173a6bff5c64ba26c09d058

#INGEST_URL=<ingest url/APU url>/api/v1/ingest/hec/raw
#INGEST_TOKEN=<token/API key>

INGEST_URL=https://sa-cluster.humio-support.com/api/v1/ingest/hec/raw
INGEST_TOKEN=acee0c08-df06-4f9f-a88b-c33dfe83c091

# This block tests against servers IDs listed in the speedtest_id.txt file.
# If the file doesn't exist the script continues to the next block.
# Ensure the file ends with a blank line or the last entry won't be tested.
if [ -r speedtest_id.txt ]; then
filename="speedtest_id.txt"
while read -r line; do
    id="$line"
    /usr/bin/speedtest -f json -s $id |
    /usr/bin/curl $INGEST_URL -X POST -H "Content-Type: text/plain; charset=utf-8" -H "Authorization: Bearer $INGEST_TOKEN" --data @-
done < "$filename"
fi

# This block will test against a server deemed by speedtest to be close to you.
# If you only want to test against servers chosen by you, comment out the next two lines.
/usr/bin/speedtest -f json |
/usr/bin/curl $INGEST_URL -X POST -H "Content-Type: text/plain; charset=utf-8" -H "Authorization: Bearer $INGEST_TOKEN" --data @-
