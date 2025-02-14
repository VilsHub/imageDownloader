#!/bin/bash
dir="/tmp/airGapTempFiles"
configsDir="$dir/configs"
imageDir="$dir/images"
trackDir="$dir/track"
dockerImageOutputDir="$dir/tempOutput"

if [ ! -d $dir ]; then
    # Directory does not exist
    mkdir -p $configsDir $imageDir $trackDir $dockerImageOutputDir
    chmod a+wr $configsDir $imageDir $trackDir $dockerImageOutputDir $dir
fi