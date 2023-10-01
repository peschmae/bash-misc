#!/bin/bash
# vim: set ft=sh :

function sync_folder() {
  one_drive_name=$1
  dest_name=$2
  echo "synching $dest_name to ${DESTINATION}"
  if [ ! -d "${DESTINATION}/informatik/${dest_name}" ]; then
    echo "${DESTINATION}/informatik/${dest_name} doesn't exist. Skipping..."
    return 1
  fi
  if [ ! -d "${ONEDRIVE_SOURCE}/${one_drive_name}/" ]; then
    echo "${ONEDRIVE_SOURCE}/${one_drive_name}/ doesn't exist. Skipping..."
    return 2
  fi
  mkdir -p "${DESTINATION}/informatik/${dest_name}/Teams-sync/"
  echo rsync -rltD --exclude=".[!.]*" --max-size="${MAX_FILE_SIZE}" "${ONEDRIVE_SOURCE}/${one_drive_name}/" "${DESTINATION}/informatik/${dest_name}/Teams-sync/"
  rsync -rltD --exclude=".[!.]*" --max-size="${MAX_FILE_SIZE}" "${ONEDRIVE_SOURCE}/${one_drive_name}/" "${DESTINATION}/informatik/${dest_name}/Teams-sync/"
}

SEMESTER=2023-hs

ONEDRIVE_SOURCE="/mnt/onedrive/"
DESTINATION="/mnt/nextcloud/$SEMESTER"

MAX_FILE_SIZE=200M

# rsync a list of folders defined above
sync_folder "E-cloud_hs23_3la_M365 - Class Materials" "3Ia/cloud"
sleep 5s

sync_folder "E-pcls_hs23_5ls_M365 - Class Materials" "5Is/pcls"
sleep 5s


# copy lastrun_timestamp to local file
LASTRUN=$(cat $ONEDRIVE_SOURCE/lastrun_timestamp | grep -oE '[0-9]*')
echo "fhnw_onedrive_last_run ${LASTRUN}" > /var/lib/node_exporter/fhnw_onedrive_sync.prom