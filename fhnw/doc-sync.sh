#! /bin/bash


set -e
trap 'catch $LINENO' ERR

unmountShare() {
  echo "unmounting share"
  sudo umount /mnt/fhnw-share
  sleep 5s
}

loginVpn() {
    set +e
    # open vpnui in background
    /opt/cisco/secureclient/bin/vpnui &

    # wait for login window to appear
    sleep 10

    # source credentials
    . vpn_credentials

    # enter username into login window
    xdotool search --name "cisco secureclient login" windowactivate %1
#    xdotool type $VPN_USERNAME
    xdotool key 0xff0d

    sleep 3

    # enter password into login window
    # would be great to detect if it's the password or 2FA question...
    xdotool type $VPN_PASSWORD
    xdotool key 0xff0d

    sleep 5

    # generate totp token and enter into login fomr
    otp_token=$(oathtool -b --totp $TOTP_SECRET)

    xdotool type $otp_token
    xdotool key 0xff0d

    sleep 5
    # accept "remember me dialog"
    xdotool key 0xff0d
    set -e
}

closeVpn() {
  # send SIQQUIT to vpnagentd process to properly disconnect
    # needs a passwordless sudo entry
    vpnagent_pid=$(ps -ef | grep vpnagentd | grep -v 'grep' | awk '{print $2}')

    sudo kill -3 $vpnagent_pid

    # kill vpnui to allow a new connection later on
    sudo pkill vpnui
}

catch() {
  echo "custom_fhnw_sync_success 0" | sudo tee /var/lib/node_exporter/fhnw_sync_success.prom
  echo "custom_fhnw_sync_last_run $(date +%s)" | sudo tee -a /var/lib/node_exporter/fhnw_sync_success.prom
  echo "An error has occured during FHNW sync, but we trapped it. Error on line $1"

  if [ -d $BASE_SOURCE ];
  then
    unmountShare
  fi

  closeVpn
}


SEMESTER=2023-hs

DESTINATION="/mnt/nextcloud/$SEMESTER"

MAX_FILE_SIZE=100M
BASE_SOURCE=/mnt/fhnw-share/E1811_Unterrichte_Bachelor
PATH_KONTEXT=E1811_Unterrichte_Kontext
PATH_I=E1811_Unterrichte_I
PATH_EIT=E1811_Unterrichte_EIT
RSYNC_EXCLUDE_STRING="--exclude-from ./rsync-exclude-list"

# connect to the VPN, using the password file
echo "Opening VPN connection"
loginVpn
sleep 15s

# mount fhnw-share
echo "Mounting share"
sudo mount -t cifs //fs.edu.ds.fhnw.ch/data/HT/ /mnt/fhnw-share -o credentials=/root/fhnw-credentials,vers=3.0
sleep 5s

# rsync a list of folders defined above
echo "synching $PATH_KONTEXT to $DESTINATION"
echo rsync -vrltD $RSYNC_EXCLUDE_STRING --max-size="$MAX_FILE_SIZE" "$BASE_SOURCE/$PATH_KONTEXT/" "$DESTINATION/kontext"
sudo rsync -vrltD $RSYNC_EXCLUDE_STRING --max-size="$MAX_FILE_SIZE" "$BASE_SOURCE/$PATH_KONTEXT/" "$DESTINATION/kontext"
sleep 5s

echo "synching $PATH_I to $DESTINATION"
echo rsync -vrltD $RSYNC_EXCLUDE_STRING --max-size="$MAX_FILE_SIZE" "$BASE_SOURCE/$PATH_I/" "$DESTINATION/informatik"
sudo rsync -vrltD $RSYNC_EXCLUDE_STRING --max-size="$MAX_FILE_SIZE" "$BASE_SOURCE/$PATH_I/" "$DESTINATION/informatik"
sleep 5s

echo "synching $PATH_EIT to $DESTINATION"
echo rsync -vrltD $RSYNC_EXCLUDE_STRING --max-size="$MAX_FILE_SIZE" "$BASE_SOURCE/$PATH_EIT/" "$DESTINATION/elektroinformationstechnik"
sudo rsync -vrltD $RSYNC_EXCLUDE_STRING --max-size="$MAX_FILE_SIZE" "$BASE_SOURCE/$PATH_EIT/" "$DESTINATION/elektroinformationstechnik"
sleep 5s


# kill vpn
unmountShare

echo "custom_fhnw_sync_success 1" | sudo tee /var/lib/node_exporter/fhnw_sync_success.prom
echo "custom_fhnw_sync_last_run $(date +%s)" | sudo tee -a /var/lib/node_exporter/fhnw_sync_success.prom

closeVpn