#! /bin/bash

# Needs a vpn_credentials file, with VPN_USERNAME, VPN_PASSWORD and TOTP_SECRET
# For the TOTP_SECRET add a new authenticator app in your o356 account,
# scan the QR code and look for the `secret` argument
#
# anyconnect UI should be configured to automatically connect to the VPN
# on startup, this avoids having to click the `connect` button after starting the UI
#
# When using this script in a cronjob make sure to set the DISPLAY env variable
# You also need to ensure that the screen doesn't lock, otherwise xdotool won't find the
# cisco windows
#

# open vpnui in background
/opt/cisco/anyconnect/bin/vpnui &

# wait for login window to appear
sleep 3

# source credentials
. vpn_credentials

# enter username into login window
xdotool search --name "cisco anyconnect login" windowactivate %1
xdotool type $VPN_USERNAME
xdotool key 0xff0d

sleep 5

# enter password into login window
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

# you should now be connected
sleep 5

# do whatever you want, eg. sync_ad, or reference doc-sync.sh
ip r

sleep 15

# send SIQQUIT to vpnagentd process to properly disconnect
# needs a passwordless sudo entry
vpnagent_pid=$(ps -ef | grep vpnagentd | grep -v 'grep' | awk '{print $2}')

sudo kill -3 $vpnagent_pid

# kill vpnui to allow a new connection later on
pkill vpnui