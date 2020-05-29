#! /bin/bash

# Arguments passed from command line
CLIENT_NAME=$1
CLIENT_IP=$2

# Config argument
INTERNAL_IP_RANGE="10.112.156.0/24"
EXTERNAL_ENDPOINT="my.ddns.example.com:51820"

# commands used in script
CLIENT_DIR=$(pwd)/client
SERVER_DIR=$(pwd)/server
WG=$(command -v wg)
WG_QUICK=$(command -v wg-quick)
TEE=$(command -v tee)
CAT=$(command -v cat)
ECHO=$(command -v echo)
GREP=$(command -v grep)
READ=$(command -v read)

if [ -f "$CLIENT_DIR/$CLIENT_NAME-privatekey" ]; then $ECHO "keys for client with name $CLIENT_NAME already exists, aborting"; exit 1; fi

$ECHO "generating private & publickey for $CLIENT_NAME"
$WG genkey | $TEE "$CLIENT_DIR/$CLIENT_NAME-privatekey" | $WG pubkey > "$CLIENT_DIR/$CLIENT_NAME-publickey"

if $WG show all allowed-ips | $GREP "$CLIENT_IP" -c > /dev/null; then $ECHO "$CLIENT_IP allready in use, you should delete the private/public keys";  exit 1; fi

$ECHO "Adding peer to server config"
$WG set wg0 peer "$($CAT "$CLIENT_DIR/$CLIENT_NAME-publickey")" allowed-ips "$CLIENT_IP/32"
$WG_QUICK save wg0 > /dev/null 2>&1

$ECHO "creating client config"
{
	$ECHO "[Interface]"
	$ECHO "Address = $CLIENT_IP"
	$ECHO "PrivateKey = $($CAT "$CLIENT_DIR/$CLIENT_NAME-privatekey")"
	$ECHO "[Peer]"
	$ECHO "PublicKey = $($CAT "$SERVER_DIR/publickey")"
	$ECHO "AllowedIPs = $INTERNAL_IP_RANGE"
	$ECHO "Endpoint = $EXTERNAL_ENDPOINT"
	$ECHO "PersistentKeepalive = 21"

} > "$CLIENT_DIR/$CLIENT_NAME.config"

$ECHO "$CLIENT_DIR/$CLIENT_NAME.config created"

$READ -p "Do you want to display the config as QR-Code? (Y/n)" -i Y input
# shellcheck disable=SC2154
if [[ $input == "Y" || $input == "y" ]]; then
	qrencode -t ansiutf8 < "$CLIENT_DIR/$CLIENT_NAME.config"
fi

