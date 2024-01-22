#!/bin/bash
read -p "Please specify the remote server host: " serverHost
read -p "Please specify the remote server username: " server_username
read -p "Please specify the remote server port, press Enter to use the default port (22): " serverPort
read -p "Please specify path to the priavte key if exist, to skip press ENTER: " privateKey
read -p "Enter the name of the helm chart: " chart_name
read -p "Enter the version number for helm chart: " version_no
read -p "Has the $chart_name chart version $version_no been downloaded before, with the temp files stil on the remote server? y/n: " downloaded

if [[ $downloaded = "y" || $downloaded = "Y" ]]; then
    # Set default port
    [ ${#serverPort} -gt 0 ] && prt=$serverPort || prt="22"

    # Set default private key
    [ ${#privateKey} -gt 0 ] && pk="-i $privateKey" || pk=""

    # Local directories and files
    l_imageDir="./imgTemp"

    # Remote directories
    dir="/tmp/airGapTempFiles"
    r_imageDir="$dir/images"
    chartImageDir="$r_imageDir/$chart_name/$version_no"

    localName="$l_imageDir/$chart_name"_"$version_no"_image_list.txt

    echo "Initiating image list download from the remote server to local server...."
    scp -P $prt $pk -r $server_username@$serverHost:$chartImageDir/$chart_name"_"$version_no"_image_list.txt" $localName
    echo -e "The image list has been downloaded successfully and saved as $localName"
else
    echo "Please kindly download the chart images first and try again"
fi