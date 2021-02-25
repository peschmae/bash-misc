#! /bin/bash

SEMESTER=2021-fs

DESTINATION="/mnt/fhnw/$SEMESTER"

MAX_FILE_SIZE=100M
BASE_SOURCE=/mnt/fhnw-share
PATH_KONTEXT=/mnt/fhnw-share/E1811_Unterrichte_Kontext
PATH_I=/mnt/fhnw-share/E1811_Unterrichte_I

# connect to the VPN, using the password file
openconnect -b --user="dilli.gaf@students.fhnw.ch" vpn.fhnw.ch < /tmp/vpn-credentials


# mount fhnw-share
mount -t cifs //fs.edu.ds.fhnw.ch/data/HT/E1811_Unterrichte_Bachelor/ /mnt/fhnw-share -o credentials=/tmp/fhnw-credentials

# rsync a list of folders defined above
echo "synching $PATH_KONTEXT to $DESTINATION"
echo rsync -rltD --exclude=".[!.]*" --max-size=50M "$BASE_SOURCE/$PATH_KONTEXT/*" "$DESTINATION/kontext"
rsync -rltD --exclude=".[!.]*" --max-size="$MAX_FILE_SIZE" "$BASE_SOURCE/$PATH_KONTEXT/*" "$DESTINATION/kontext"

echo "synching $PATH_I to $DESTINATION"
echo rsync -rltD --exclude=".[!.]*" --max-size=50M "$BASE_SOURCE/$PATH_I/" "$DESTINATION/informatik"
rsync -rltD --exclude=".[!.]*" --max-size="$MAX_FILE_SIZE" "$BASE_SOURCE/$PATH_I/" "$DESTINATION/informatik"

# kill vpn
umount /mnt/fhnw-share
pkill -SIGINT openconnect