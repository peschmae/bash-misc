#!/bin/bash
# vim: set ft=sh :

SEMESTER=2022-fs

ONEDRIVE_SOURCE="/mnt/onedrive/"
DESTINATION="/mnt/nextcloud/$SEMESTER"

MAX_FILE_SIZE=100M

# example, don't remove this!
# echo "synching 3Ibb(1|2)/algd1 to $DESTINATION"
# echo rsync -rltD --exclude=".[!.]*" --max-size="$MAX_FILE_SIZE" "$ONEDRIVE_SOURCE/Algd1_21H_3Ibb_M365 - Kursmaterialien/" "$DESTINATION/informatik/3Ibb1/algd1/Teams-synch/"
# rsync -rltD --exclude=".[!.]*" --max-size="$MAX_FILE_SIZE" "$ONEDRIVE_SOURCE/Algd1_21H_3Ibb_M365 - Kursmaterialien/" "$DESTINATION/informatik/3Ibb1/algd1/Teams-synch/"
# sleep 5s

# rsync a list of folders defined above
echo "synching 4Ibb2/algd2 to $DESTINATION"
echo rsync -rltD --exclude=".[!.]*" --max-size="$MAX_FILE_SIZE" "$ONEDRIVE_SOURCE/E-fs22-algd2-4Ibb2_M365 - Class Materials/" "$DESTINATION/informatik/4Ibb2/algd2/Teams-synch/"
rsync -rltD --exclude=".[!.]*" --max-size="$MAX_FILE_SIZE" "$ONEDRIVE_SOURCE/E-fs22-algd2-4Ibb2_M365 - Class Materials/" "$DESTINATION/informatik/4Ibb2/algd2/Teams-synch/"
sleep 5s

# copy lastrun_timestamp to local file
LASTRUN=$(cat $ONEDRIVE_SOURCE/lastrun_timestamp | grep -oE '[0-9]*')
echo "fhnw_onedrive_last_run ${LASTRUN}" > /var/lib/node_exporter/fhnw_onedrive_sync.prom
