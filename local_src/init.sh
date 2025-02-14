#!/bin/bash
dir="/tmp/airGapTempFiles/tempOutput"
configsDir="$dir/configs"
imageDir="$dir/images"
trackDir="$dir/track"
dockerImageOutputDir="$dir/tempOutput"

if [ ! -d $dir ]; then
    # Directory does not exist
    mkdir -p $configsDir $imageDir $trackDir $dockerImageOutputDir
fi