#! /bin/bash

set -e
trap 'catch' ERR


# Internals
VPN_PID_FILE="/tmp/vpn.pid"

unmountShare() {
  echo "unmounting share"
  umount /mnt/fhnw-share
  sleep 5s
}

closeVpn() {
  echo "kill openconnect using sigint"
  kill -SIGINT $(<$VPN_PID_FILE)
}

catch() {
  echo "custom_fhnw_sync_success 0" > /var/lib/node_exporter/fhnw_sync_success.prom
  echo "custom_fhnw_sync_last_run $(date +%s)" > /var/lib/node_exporter/fhnw_sync_success.prom
  echo "An error has occured during FHNW sync, but we trapped it"

  if [ -d $BASE_SOURCE ];
  then
    unmountShare
  fi

  if [ -f $VPN_PID_FILE ];
  then
    closeVpn
  fi
}


SEMESTER=2021-hs

DESTINATION="/mnt/nextcloud/$SEMESTER"

MAX_FILE_SIZE=100M
BASE_SOURCE=/mnt/fhnw-share/E1811_Unterrichte_Bachelor
PATH_KONTEXT=E1811_Unterrichte_Kontext
PATH_I=E1811_Unterrichte_I


if [ -f $VPN_PID_FILE ];
then
    echo "custom_fhnw_sync_success 0" > /var/lib/node_exporter/fhnw_sync_success.prom
    echo "VPN pid file exists, aborting"
    exit 1
fi

# connect to the VPN, using the password file
echo "Opening VPN connection"
/usr/sbin/openconnect -v --timestamp -b --pid-file $VPN_PID_FILE --user="dilli.gaf@students.fhnw.ch" vpn.fhnw.ch < /tmp/vpn-password
sleep 15s

# mount fhnw-share
echo "Mounting share"
mount -t cifs //fs.edu.ds.fhnw.ch/data/HT/ /mnt/fhnw-share -o credentials=/root/fhnw-credentials,vers=3.0
sleep 5s

# rsync a list of folders defined above
echo "synching $PATH_KONTEXT to $DESTINATION"
echo rsync -vrltD --exclude=".[!.]*" --exclude="*.lnk" --max-size="$MAX_FILE_SIZE" "$BASE_SOURCE/$PATH_KONTEXT/" "$DESTINATION/kontext"
rsync -vrltD --exclude=".[!.]*" --exclude="*.lnk" --max-size="$MAX_FILE_SIZE" "$BASE_SOURCE/$PATH_KONTEXT/" "$DESTINATION/kontext"
sleep 5s

echo "synching $PATH_I to $DESTINATION"
echo rsync -vrltD --exclude=".[!.]*" --exclude="*.lnk" --max-size="$MAX_FILE_SIZE" "$BASE_SOURCE/$PATH_I/" "$DESTINATION/informatik"
rsync -vrltD --exclude=".[!.]*" --exclude="*.lnk" --max-size="$MAX_FILE_SIZE" "$BASE_SOURCE/$PATH_I/" "$DESTINATION/informatik"
sleep 5s


# kill vpn
unmountShare

echo "custom_fhnw_sync_success 1" > /var/lib/node_exporter/fhnw_sync_success.prom
echo "custom_fhnw_sync_last_run $(date +%s)" > /var/lib/node_exporter/fhnw_sync_success.prom

closeVpn