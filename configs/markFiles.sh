#!/bin/bash

# Remote directories
dir="/tmp/airGapTempFiles"
configsDir="$dir/configs"
imageDir="$dir/images"

trackDir="$dir/track/docker"
dockerImageDir="$imageDir/docker"
output=$dir"/tempOutput"
type=$1
imageListFile=$2


if [ ! -d $output ]; then
    # Directory does not exist
    mkdir -p $output
    chmod a+wr $output
else
    # empty the directory
    rm -fr $output/*
fi

if [[ $type = "3" || $type = "4" ]]; then 
    # specific  pulled Docker images
    
    echo -e "Initiating marking of images to be downloaded...\n"

    while read image; do
        # check if images is downloaded aleady
        image_name=$(echo $image | cut -d'/' -f 2)

        if [ $type = "4" ]; then
            # specific  pulled Chart images 
            chartName=$3
            versionNo=$4
            targetImage="$imageDir/$chartName/$versionNo/$image_name.tar.gz"
        else
            targetImage="$dockerImageDir/$image_name.tar.gz"
        fi

        # Check for target files and mark
        if [ -f $targetImage ]; then
            # File exist, copy to output directory
            cp $targetImage $output/$image_name.tar.gz
            echo -e "The image $image_name has been marked for download\n"   
        else
            echo -e "Error: The  $image_name image has not been pulled yet, kindly try downloading the image before attempting to download the pulled images\n"
        fi

    done < "$configsDir/$imageListFile"

fi