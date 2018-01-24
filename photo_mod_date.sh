#!/bin/bash

# Designate path to operate
read -p "Enter path: " PHOTO_FOLDER_PATH
# Options
read -p "Do you want check for files without geotagging (y=yes | n=no): " GEOTAG_CHECK
read -p "Do you want to reset date (y=yes | n=no): " ORIGINDATE
read -p "Do you want to apply Geotags (y=yes | n=no): " GEOTAGS

if [ "$GEOTAG_CHECK" == "y" ]; then
    NUM_NOT_GEOTAGGED=0
    FILES_NO_GEOTAGS=()
fi

if [ "$GEOTAGS" == "y" ]; then
    echo "Fill in geotagging info"
    read -p "Enter latitude: " LATITUDE
    read -p "Enter latitude ref: " LATITUDE_REF
    read -p "Enter longitude: " LONGITUDE
    read -p "Enter longitude ref: " LONGITUDE_REF
fi

for entry in "$PHOTO_FOLDER_PATH"/* 
do

    if [ "$GEOTAG_CHECK" == "y" ]; then
        FOUND_GPSTAG=$(exiftool "$entry" | grep -c "GPS")
        if [ "$FOUND_GPSTAG" == 0 ]; then
            NUM_NOT_GEOTAGGED=$((NUM_NOT_GEOTAGGED + 1))
            FILES_NO_GEOTAGS+=("$entry")
        fi
    fi

    if [ "$GEOTAGS" == "y" ]; then
        exiftool -GPSLongitudeRef="$LONGITUDE_REF" -GPSLongitude="$LONGITUDE" -GPSLatitudeRef="$LATITUDE_REF" -GPSLatitude="$LATITUDE" -overwrite_original "$entry"
    fi

    if [ "$ORIGINDATE" == "y" ]; then
        #    exiftool -T -createdate "$entry"
        CREATE_DATE=$(exiftool -T -dateTimeOriginal "$entry")
        echo "$CREATE_DATE"

        NEW_DATE=""

        IFS=' ' read -ra DATEARRAY <<< "$CREATE_DATE"
        for i in "${DATEARRAY[@]}"; 
        do
            IFS=':' read -ra DATEARRAY2 <<< "$i"  
            #echo "${DATEARRAY2[@]}"
            for e in "${DATEARRAY2[@]}"; 
            do
                NEW_DATE="$NEW_DATE$e"
                #echo "$NEW_DATE"
            done
            NEW_DATE=${NEW_DATE:0:12}  
        done
    
        touch -t "$NEW_DATE" "$entry"
    fi
done


if [ "$GEOTAG_CHECK" == "y" ]; then
    echo "$NUM_NOT_GEOTAGGED"
    printf '%s\n' "${FILES_NO_GEOTAGS[@]}"
fi



