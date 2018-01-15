#!/bin/bash

cd /src/astrometry/net
export PYTHONPATH=${PYTHONPATH}:.
for ((;;)); do python process_submissions.py -s 4 -j 16 > dj.log 2>&1; sleep 1; done


