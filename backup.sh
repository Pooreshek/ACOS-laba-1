#!/bin/bash

LOG_DIR=$1
THRESHOLD=$2
M_FILES=$3
BACKUP_DIR="/backup"

if [[ $# -ne 3 ]]; then
    echo "Error: Incorrect arguments. Expected: 3"
    exit 1
fi

if (( THRESHOLD < 0 || THRESHOLD > 100 )); then
    echo "Error: THRESHOLD must be between 0 and 100."
    exit 1
fi

if [[ ! "$M_FILES" =~ ^[1-9][0-9]*$ ]]; then
    echo "Error: M_FILES must be a real integer."
    exit 1
fi

if [ ! -d "$LOG_DIR" ]; then
        echo "Folder $LOG_DIR is not found!"
        exit 1
fi

USAGE_PERCENT=$(df "$LOG_DIR" | tail -1 | awk '{print $5}' | tr -d '%')

echo "Usage percent: $USAGE_PERCENT%"

if [ "$USAGE_PERCENT" -gt "$THRESHOLD" ]; then
	echo "The limits are overrun, archivation started"

        if [ ! -d "$BACKUP_DIR" ]; then
                sudo mkdir -p "$BACKUP_DIR" && sudo chmod 700 "$BACKUP_DIR"
        fi

        cd "$LOG_DIR"
        OLD_FILES=$(ls -tr | grep "log" | head -n "$M_FILES")

        ARCHIVE_NAME="$BACKUP_DIR/backup_$(date +%Y%m%d_%H%M%S).tar.gz"

        echo "Archiving..."
        sudo tar -czf "$ARCHIVE_NAME" $OLD_FILES

        if [ $? -eq 0 ]; then
                echo "Old files archived successfuly"
        fi
else
        echo "Archivation is not requiered"
fi
