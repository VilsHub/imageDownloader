#!/bin/bash
# Get the pull type
PS3="Please select the type of pulled images to be downloaded: "
pullType=("All docker images" "All pulled chart images" "Specific pulled docker images" "Specific pulled chart images")
selectedOpt=0
chart_name=""

select res in "${pullType[@]}"; do
    selectedOpt=$REPLY
    while [[ $REPLY != "1" && $REPLY != "2" && $REPLY != "3" && $REPLY != "4" ]]; do
        PS3="Please select a valid option for the pulled images to be downloaded: "
        select res in "${pullType[@]}"; do
            selectedOpt=$REPLY
            break
        done
    done
    break
done

# Local directories and files
init="./src/init.sh"
l_imageDir="./imgTemp/"
l_configsDir="./configs"

read -p "Please specify the remote server host: " serverHost
read -p "Please specify the remote server username: " server_username
read -p "Please specify the remote server port, press Enter to use the default port (22): " serverPort
read -p "Please specify path to the private key if exist, to skip press ENTER: " privateKey

# Set default port
[ ${#serverPort} -gt 0 ] && prt=$serverPort || prt="22"

# Set default private key
[ ${#privateKey} -gt 0 ] && pk="-i $privateKey" || pk=""

# Remote directories
dir="/tmp/airGapTempFiles"
r_configsDir="$dir/configs"
r_imageDir="$dir/images"
dockerImageDir="$r_imageDir/docker"


if [ $selectedOpt = "1" ]; then
    # Download pulled docker images

    echo "Initiating image download from the remote server to local server...."
    scp -P $prt $pk -r $server_username@$serverHost:$dockerImageDir/* $l_imageDir
    echo -e "All images has been downloaded successfully....\n"

elif [ $selectedOpt = "2" ]; then
    # Download all pulled chart images
    read -p "Enter the name of the helm chart: " chart_name
    read -p "Enter the version number for helm chart: " version_no

    chartImageDir="$r_imageDir/$chart_name/$version_no"

    echo "Initiating image download from the remote server to local server...."
    scp -P $prt $pk -r $server_username@$serverHost:$chartImageDir/* $l_imageDir
    echo -e "All images has been downloaded successfully....\n"

elif [ $selectedOpt = "3" ]; then
    # Specific pulled docker images
    read -p "Please specify the file name in the ./configs directory which contains the names of the images to be downloaded: " image_list_file

    # # Check if file exist
    if [ ! -f "$l_configsDir/$image_list_file" ]; then
        found=0
        while [ $found -eq 0 ]; do
            read -p "The '$image_list_file' is not found in the  $l_configsDir directory, please specify the file name in the ./configs directory which contains the names of the images to be downloaded: " image_list_file
            if [ -f "$l_configsDir/$image_list_file" ]; then
                found=1
            fi
        done
    fi
elif [ $selectedOpt = "4" ]; then
    # Specific pulled chart images
    read -p "Enter the name of the helm chart: " chart_name
    read -p "Enter the version number for helm chart: " version_no
    read -p "Has the $chart_name chart version $version_no been downloaded before, with the temp files stil on the remote server? y/n: " downloaded

    if [[ $downloaded = "y" && $downloaded = "Y" ]]; then
        echo "Please kindly download the chart images first and try again"
        exit 2
    fi

    # Specific pulled docker images
    read -p "Please specify the file name in the ./configs directory which contains the names of the images to be downloaded: " image_list_file

    # # Check if file exist
    if [ ! -f "$l_configsDir/$image_list_file" ]; then
        found=0
        while [ $found -eq 0 ]; do
            read -p "The '$image_list_file' is not found in the  $l_configsDir directory, please specify the file name in the ./configs directory which contains the names of the images to be downloaded: " image_list_file
            if [ -f "$l_configsDir/$image_list_file" ]; then
                found=1
            fi
        done
    fi
fi


if [[ $selectedOpt = "3" || $selectedOpt = "4" ]]; then
    
    # Set default value for option 4 if not selected
    : ${chart_name:=""}
    : ${version_no:=""}

    echo "Initiating environment setup on remote server...."
    # Setup directories
    ssh -p $prt $pk $server_username@$serverHost < $init
    echo -e "Environment setup on remote server completed successfully....\n"

    # Copy configs to remote server
    echo "Initiating copying of config files to the remote server...."
    scp -pP $prt $pk -r $l_configsDir/* $server_username@$serverHost:$r_configsDir/ &&
    echo -e "Copied config files  successfully to the remote server\n"

    echo "Initiating logging in to remote server, and marking of images for download..."
    ssh -tp $prt $pk $server_username@$serverHost sudo "$r_configsDir/markFiles.sh" $selectedOpt $image_list_file $chart_name $version_no
    echo -e "Image marking completed successfully\n"

    echo "Initiating image download from the remote server to local server...."
    scp -P $prt $pk -r $server_username@$serverHost:$dir/tempOutput/* $l_imageDir
    echo -e "All images has been downloaded successfully....\n"

fi