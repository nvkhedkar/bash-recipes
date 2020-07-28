#!/bin/bash

sed_stuff()
{
    local infile=$1
    
    # print matching patterns
    echo "option -r: extended regex"
    echo "option /p: print matching stuff"
    sed -n -r "/^\s*some\.property\.value\s+\=\s+/p" $infile

    # replace matching patterns
    echo "option -i: in-place"
    echo "option /g: will replace globally"
    sed -i -r "/^\s*some\.property\.value\s+\=\s+[0-9]+/some\.property\.value = 12345/g" $infile

    # same as above using captured groups
    sed -i -r "/^\s*(some\.property\.value)(\s+\=)\s+[0-9]+/\1\2 12345/" $infile
}
