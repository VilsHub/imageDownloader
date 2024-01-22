#!/bin/bash
dir="/tmp/airGapTempFiles"
configsDir="$dir/configs"
imageDir="$dir/images"
trackDir="$dir/track"

if [ ! -d $dir ]; then
    # Directory does not exist
    mkdir -p $configsDir $imageDir $trackDir
fi