#!/bin/bash

LOG_DIR=$1
THRESHOLD=$2
M_FILES=$3
BACKUP_DIR="/backup"

if [ ! -d $LOG_DIR ]; then
        echo "Folder $LOG_DIR is not found!"
        exit 1
fi

USAGE_PERCENT=$(df $LOG_DIR | tail -1 | awk '{print $5}' | tr -d '%')

echo "Usage percent: $USAGE_PERCENT%"

if [ $USAGE_PERCENT -gt $THRESHOLD ]; then
	echo "The limits are overrun, archivation started"

        if [ ! -d $BACKUP_DIR ]; then
                sudo mkdir -p $BACKUP_DIR && sudo chmod 777 $BACKUP_DIR
        fi

        cd $LOG_DIR
        OLD_FILES=$(ls -tr | grep "log" | head -n $M_FILES)

        ARCHIVE_NAME="$BACKUP_DIR/backup_$(date +%Y%m%d).tar.gz"

        echo "Archiving..."
        sudo tar -czf $ARCHIVE_NAME $OLD_FILES

        if [ $? -eq 0 ]; then
                rm -f $OLD_FILES
                echo "Old files removed successfuly"
        fi
else
        echo "Archivation is not requiered"
fi
