#! /bin/bash

set -e

# Careful about writing things to stdout - we pipe it to tar on the other end.

cd /src/astrometry/blind
PWD=$(pwd)
BACKEND="$PWD/astrometry-engine"

# Read jobid
read -s jobid

# Create our job directory.
cd /tmp
mkdir -p $jobid
cd $jobid
# Delete previous contents... carefully
rm -f wcs.fits job.axy

export TMP=/tmp

echo "In job dir $(pwd)" > backend.log
tar xvf - >> backend.log

CFG=/src/astrometry/net/docker.cfg
# stderr goes back over the ssh tunnel to the log file on oven.
$BACKEND -v --to-stderr -c $CFG job.axy >> backend.log

# Send back all the files we generated!
tar cf - --exclude job.axy *


