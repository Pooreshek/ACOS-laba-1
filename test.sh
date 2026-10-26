#!/bin/bash

TEST_DIR="/log"
BACKUP_DIR="/backup"

sudo umount $TEST_DIR 2>/dev/null
sudo rm -rf $TEST_DIR
sudo rm -rf $BACKUP_DIR/* 2>/dev/null

sudo mkdir -p $TEST_DIR && sudo chmod 777 $TEST_DIR

echo "Creating the virtual disk..."
sudo mount -t tmpfs -o size=100M tmpfs $TEST_DIR
sudo chmod 777 $TEST_DIR

echo "Creating the test files 10x1mb"
for i in {1..10}; do
    if [ $i -lt 10 ]; then
        NAME="log0$i.txt"
    else
        NAME="log$i.txt"
    fi
    dd if=/dev/zero of=$TEST_DIR/$NAME bs=1k count=1024 2>/dev/null
    touch -m -d "$((i * 10)) minutes ago" $TEST_DIR/$NAME
done

echo "FIRST TEST (TRESHHOLD IS AT 95%)"
./backup.sh $TEST_DIR 95 3

echo "SECOND TEST (THRESHOLD IS AT 5%)"
./backup.sh $TEST_DIR 5 3

echo "THIRD TEST (WRONG LOG_DIR)"
./backup.sh 132 95 3

echo "FOURTH TEST (ONLY TWO ARGUMENTS)"
./backup.sh $TEST_DIR 5 

echo "FIFTH TEST (THRESHOLD IS 105)"
./backup.sh $TEST_DIR 105 3

echo "SIXTH TEST (M_FILES IS -3)"
./backup.sh $TEST_DIR 5 -3

echo "RESULTS"

echo "Number of files in the logs direcrtory (expected 3):"
ls -1 $BACKUP_DIR | wc -l

read

echo "Demolishing the virtual disk..."
sudo umount $TEST_DIR
