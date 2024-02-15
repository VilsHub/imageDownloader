#!/bin/bash
# Get the download type
PS3="Please select the type of images to be downloaded: "
downloadType=("Docker images" "Chart images")
selectedOpt=0

select res in "${downloadType[@]}"; do
    selectedOpt=$REPLY
    while [[ $REPLY != "1" && $REPLY != "2" ]]; do
        PS3="Please select a valid option for the image type to be downloaded: "
        select res in "${downloadType[@]}"; do
            selectedOpt=$REPLY
            break
        done
    done
    break
done

read -p "Please specify the remote server host: " serverHost
read -p "Please specify the remote server username: " server_username
read -p "Please specify the remote server port, press Enter to use the default port (22): " serverPort
read -p "Please specify path to the private key if exist, to skip press ENTER: " privateKey

# # Set default port
[ ${#serverPort} -gt 0 ] && prt=$serverPort || prt="22"

# Set default private key
[ ${#privateKey} -gt 0 ] && pk="-i $privateKey" || pk=""

# Local directories and files
init="./src/init.sh"
l_imageDir="./imgTemp/"
l_configsDir="./configs"

if [ $selectedOpt = "1" ]; then
    # Docker image download
    read -p "Please specify the file name in the ./configs directory which contains the names of the images to be doownloaded: " image_list_file

    # # Check if file exist
    if [ ! -f "$l_configsDir/$image_list_file" ]; then
        found=0
        while [ $found -eq 0 ]; do
            read -p "The '$image_list_file' is not found in the  $l_configsDir directory, please specify the file name in the ./configs directory which contains the names of the images to be doownloaded: " image_list_file
            if [ -f "$l_configsDir/$image_list_file" ]; then
                found=1
            fi
        done
    fi
else
    # Download chart images
    read -p "Enter the name of the helm chart: " chart_name
    read -p "Enter the version number for helm chart: " version_no
    read -p "Enter the repository of the helm chart: " rps
    read -p "Please specify the .yaml file name in the ./configs directory to be used: " yaml_file

    # Check if file exist
    if [ ! -f "$l_configsDir/$yaml_file" ]; then
        found=0
        while [ $found -eq 0 ]; do
            read -p "The '$yaml_file' is not found in the  $l_configsDir directory, please specify the .yaml file name in the ./configs directory to be used: " yaml_file
            if [ -f "$l_configsDir/$yaml_file" ]; then
                found=1
            fi
        done
    fi
fi

# Remote directories
dir="/tmp/airGapTempFiles"
r_configsDir="$dir/configs"
r_imageDir="$dir/images"
dockerImageOutputDir="$dir/tempOutput"


echo "Initiating environment setup on remote server...."
# Setup directories
ssh -p $prt $pk $server_username@$serverHost < $init
echo -e "Environment setup on remote server completed successfully....\n"

# Copy configs to remote server
echo "Initiating copying of config files to the remote server...."
scp -pP $prt $pk -r $l_configsDir/* $server_username@$serverHost:$r_configsDir/ &&
echo -e "Copied config files  successfully to the remote server\n"

echo "Initiating logging in to remote server, and downloading of images..."
if [ $selectedOpt = "1"  ]; then
    # Docker images download
    ssh -tp $prt $pk $server_username@$serverHost sudo "$r_configsDir/directImageDownload.sh" $image_list_file
else
    chartImageDir="$r_imageDir/$chart_name/$version_no"
    # Chart images download
    ssh -tp $prt $pk $server_username@$serverHost sudo "$r_configsDir/downloadAndCompressImages.sh" $version_no $yaml_file $chart_name $rps
fi
echo -e "Image download completed successfully\n"

echo "Initiating image download from the remote server to local server...."

[ $selectedOpt = "1" ] && sourceDir=$dockerImageOutputDir || sourceDir=$chartImageDir

scp -P $prt $pk -r $server_username@$serverHost:$sourceDir/* $l_imageDir
echo -e "All images has been downloaded successfully....\n"