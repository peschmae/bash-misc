#!/bin/bash
# This script fetches the current external IP Address, writes out an nsupdate file
# Then performs an nsupdate to our remote server of choice
# This script should be placed on a 10 minute crontab

usage="$(basename "$0") [-h] -k <KEYNAME> -f <KEYFILE> -d <DOMAIN> -z <ZONE> [-s <SERVER>] [-t <TTL>] -- Update DNS A records using nsupdate

where:
    -h , --help         show this help text
    -k , --key          key name
    -f , --key-file     absolute path to the keyfile
    -d , --domain       domain to update
    -z , --zone         DNS zone
    -s , --server       Server to send the update request to
    -t , --ttl          TTL in seconds"

DOMAIN=""
ZONE=""
SERVER=""
KEYNAME=""
KEYFILE="/dev/null"
TTL="600"
DEBUG=false

while [ "$1" != "" ]; do
    case $1 in
        -k | --key )            shift
                                KEYNAME=$1
                                ;;
        -f | --key-file )       shift
                                KEYFILE=$1
                                ;;
        -d | --domain )         shift
                                DOMAIN=$1
                                ;;
        -z | --zone )           shift
                                ZONE=$1
                                ;;
        -s | --server )         shift
                                SERVER=$1
                                ;;
        -t | --ttl )            shift
                                TTL=$1
                                ;;
        --debug )               DEBUG=true
                                ;;
        -h | --help )           echo "$usage"
                                exit
                                ;;
        * )                     echo "$usage"
                                exit 1
    esac
    shift
done

WGET=$(command -v wget)
ECHO=$(command -v echo)
NSUPDATE=$(command -v nsupdate)

KEYFILECONTENT=$(cat "$KEYFILE")
if [ "$KEYFILECONTENT" == "" ]; then
        $ECHO "KEY FILE EMPTY. ABORT"
        exit 1;
fi

IP=$($WGET -q -O - https://api.ipify.org)

{
    $ECHO "server $SERVER"
    $ECHO "key $KEYNAME $KEYFILECONTENT"
} > /tmp/nsupdate
if [ "$DEBUG" = true ]; then
        $ECHO "debug yes" >> /tmp/nsupdate
fi
{
    $ECHO "zone $ZONE"
    $ECHO "update delete $DOMAIN"
    $ECHO "update add $DOMAIN $TTL A $IP"
    $ECHO "send"
} >> /tmp/nsupdate

if [ "$DEBUG" = true ]; then
        $ECHO "Content of /tmp/nsupdate"
        cat /tmp/nsupdate
fi

$NSUPDATE /tmp/nsupdate
