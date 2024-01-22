#!/bin/bash
read -p "Delete image file after importation? y/n: " d_image

# Local directories and files
l_imageDir="./imgTemp"
echo -e  "Initating extraction of downloaded images....\n"

downloadedImages=$(ls "$l_imageDir"/*.tar.gz 2> /dev/null)

if [ -n "$downloadedImages" ]; then
    for file in $downloadedImages; do
        imageName=$(basename $file)
        echo "Now extracting: $imageName"
        gunzip "$file"
    done
else
    echo -e "No image found for extraction\n"
fi

extractedImages=$(ls "$l_imageDir"/*.tar 2> /dev/null)

if [ -n "$extractedImages" ]; then
    echo -e "All downloaded files extracted successfully....\n"
    echo "Initiating Image import process...."

    for file in $extractedImages; do
        imageName=$(basename $file)
        echo "Importing image: $imageName"
        ctr -n=k8s.io images import "$file" &&

        #Delete the tar ball after import
        if [[ $d_image = "y" || $d_image = "Y" ]]; then
            rm -f "$file"
        fi
        
        echo -e "\n"
    done

    echo -e  "All images imported successfully....\n"
fi
