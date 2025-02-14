#!/bin/bash

# Remote directories
dir="/tmp/airGapTempFiles"
configsDir="$dir/configs"
imageDir="$dir/images"
dockerImageOutputDir="$dir/tempOutput"

trackDir="$dir/track/docker"
dockerImageDir="$imageDir/docker"

if [ ! -d $dockerImageDir ]; then
    # Directory does not exist
    mkdir -p $dockerImageDir
    chmod a+wr $dockerImageDir
fi

if [ ! -d $trackDir ]; then
    # Directory does not exist
    mkdir -p $trackDir
    chmod a+wr $trackDir
    chmod a+wr $dir/track
fi

if [ ! -f "$dir/error" ]; then
    # Create error file
    touch "$dir/error"
    chmod a+w "$dir/error"
fi

# Clear tempOutputDir
rm -f $dockerImageOutputDir/*

imageListFile=$1

# Download and compress images
echo -e "Initiating pulling and saving of docker images....\n"

while read image; do
    # check if images is downloaded aleady
    image_name=$(echo $image | cut -d'/' -f 2)
    e_image="$trackDir/$image_name.track"

    retrieved=0
    if [ -f $e_image ]; then
        # File exist
        echo -e "The image $image_name has been downloaded already\n"
        retrieved=1
    else
        echo "Pulling image $image"
        docker pull $image 2> "$dir/error"

        ec=$?

        if [ $ec -eq 0 ]; then

            echo "Saving image $image_name"
            docker save $image > "$dockerImageDir/$image_name.tar" &&

            # Set permissions
            chmod a+w "$dockerImageDir/$image_name.tar"

            echo "Compressing image $image_name"
            gzip "$dockerImageDir/$image_name.tar" &&
            
            # Set permissions
            chmod a+w "$dockerImageDir/$image_name.tar.gz"

            # track completely downloaded image
            touch $e_image

            # Set permissions
            chmod a+w $e_image
            retrieved=1
            echo -e "\n"

        else

            echo -e "The error below occured while pulling the image $image_name.\n "
            cat "$dir/error"
            echo -e "\n"
            
        fi
    fi

    if [ $retrieved -eq 1 ]; then
        # Copy image file to dockerImageOutputDir
        echo "Marking it for download......"
        cp -p $dockerImageDir/$image_name.tar.gz $dockerImageOutputDir/

    fi
done < "$configsDir/$imageListFile"

echo "All images pulled, saved and compressed successfully..."