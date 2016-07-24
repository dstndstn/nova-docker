#! /bin/bash

# Run via:
#   python process_submissions.py --solve-locally=$(pwd)/solvescript.sh

set -e

jobid=$1
axyfile=$2

BACKEND="/src/astrometry/blind/astrometry-engine"
CFG="/src/astrometry/net/docker.cfg"
export TMP=/tmp

$BACKEND -v -c $CFG $axyfile
