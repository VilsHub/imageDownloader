#!/bin/bash
cleanUpType=$1 #type 1 => clean all, and type 2 => clean specific
chartName=$2
dir="/tmp/airGapTempFiles"
imageDir="$dir/images"
trackDir="$dir/track"
chartDir="$imageDir/$chartName"
trackFiles="$trackDir/$chartName"_*

if [ $cleanUpType = "2" ]; then
    if [ -d $chartDir ]; then
        # remove directory
        rm -rf $chartDir
        rm -f $trackFiles
    else
        echo -e "No temp files for found for the $chartName chart\n"
    fi
else
    if [ -d $dir ]; then
        # remove directory
        rm -rf $dir
    fi
fi