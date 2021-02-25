#! /bin/bash

## Change this!
MODULE=bsys
CLASS=2Ia
# either informatik or kontext
MODULE_TYPE=informatik
SEMESTER=2021-fs

## OwnCloud related
DOWNLOAD_URL=https://drive.switch.ch/index.php/s/<DOWNLOAD>/download
MAIN_FOLDER=Betriebssysteme

## FIXED VARS
MNT_FHNW="/mnt/fhnw"
SYNC_DEST="$MNT_FHNW/$SEMESTER/$MODULE_TYPE/$CLASS/$MODULE"
MAX_FILE_SIZE=100M

wget -O "$MODULE-sync.zip" "$DOWNLOAD_URL"

unzip "$MODULE-sync.zip"

cd $MAIN_FOLDER || exit

rsync -rl --exclude=".[!.]*" --max-size="$MAX_FILE_SIZE" . "$SYNC_DEST"

# CLEANUP
cd .. || exit
rm -rf "$MAIN_FOLDER"
rm "$MODULE-sync.zip"