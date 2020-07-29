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

    # print only matching stuff
    # following will print only 'value'
    sed -En -r "s|^\s*some\.(property)\.(value)\s+\=\s+|\2|p" $infile

    # Non-greedy match for a space - matches first space
    # [^\s]*\s+ : 
    # [^\s]     : Do not look for space
    # [^\s]*    : With * look for anything but space
    # [^\s]*\s+ : With * look for anything but space then get first space
    sed -En -r "s|^\s*some\.(property)\.(value)\s+\=[^\s]*\s+|\2|p" $infile

    # perl escaping single quote
    # You can't directly escape it within single quotes, so to get a single quote you need to do something like:
    # to match: hello 'nikhil' 
    # regex is perl -ne 'print if /nikhil'\''/' $some_file
    # '\'' - first end single quote with ' - then escape with \' - then again resume with ' 
    # example:
    # args '--spring.profiles.active=profile-default'

    profile1="profile-special"
    gradle_file="./some_dir/build.gradle"
    echo "replace..."
    perl -ne 'print "$1\n" if /(--spring\.profiles\.active\=.*)'\''/' $gradle_file
    # prints: --spring.profiles.active=profile-default
    perl -i -pe 's/(--spring\.profiles\.active)\=.*'\''/$1='$profile1\''/' $gradle_file
    echo "with"
    perl -ne 'print "$1\n" if /(--spring\.profiles\.active\=.*)'\''/' $gradle_file
    echo "done."
}
