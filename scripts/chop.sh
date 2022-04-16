#!/bin/sh

grep -v "//" $1 | xargs -n $2 | nl -w 4 -n rz -i $2 -v 0 -s " | " > ${1%.*}_chopped.txt