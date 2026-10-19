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

echo -e "FIRST TEST (TRESHHOLD IS AT 95%)"
./backup.sh $TEST_DIR 95 3

echo -e "SECOND TEST (THRESHOLD IS AT 5%)"
./backup.sh $TEST_DIR 5 3

echo -e "RESULTS"
echo "Files in the $BACKUP_DIR"
ls -l $BACKUP_DIR

echo "Number of files left in the logs direcrtory (expected 7):"
ls -1 $TEST_DIR | wc -l

echo -e "Demolishing the virtual disk..."
sudo umount $TEST_DIR

