#! /bin/bash

# This script starts all guests that exist in a specific directory
# You can either symlink the qemu config files, or just touch a file that has
# the same name as the guest.
# We don't parse the XML to get the proper guest name anyway.

set -e

usage="
Usage: $(basename "$0") [OPTIONS]

Options:
  -d, --directory              Directory to scan for guest files, all found guests will be started, this is a mandatory option
  --nfs-server                 IP address for an NFS server, if provided we check if the default port 2049 is open, before starting the guests
  -h, --help                   Displays this help text
"

if [ -z "$1" ]
then
    echo "$usage"
    exit 1
fi

for i in "$@"
do
case $i in
    -d=*|--directory=*)
    VM_FOLDER="${i#*=}"
    shift # past argument=value
    ;;
    --nfs-server=*)
    NFS_SERVER="${i#*=}"
    shift # past argument=value
    ;;
esac
done

if [ -z "$VM_FOLDER" ]
then
    echo "No directory provided, aborting"
    echo "$usage"
    exit 1
fi

# Check if port 2049 is up and running, some might consider showmount the better solution
# but showmount doesn't allow setting a timeout, what I dislike quite a bit
if [ "$NFS_SERVER" ]
then
    NFS_COUNTER=0
    while ! nc -vz "$NFS_SERVER" 2049 &> /dev/null;
    do
        if [ $NFS_COUNTER -gt 20 ]
        then
            echo "NFS server didn't respond after 10 minutes, aborting"
            exit 1
        fi
        # NFS server didn't respond on port 2049, sleeping for 30s
        sleep 30
        ((NFS_COUNTER++))
    done
fi


if [ -d "$VM_FOLDER" ]
then
    echo "Starting all guests symlinked to $VM_FOLDER"
    for GUEST_FILE in "$VM_FOLDER"/*.xml
    do
        GUEST_NAME="${GUEST_FILE##*/}"
        GUEST_NAME="${GUEST_NAME%.xml}"
        echo "Checking if $GUEST_NAME is already running"
        if ! virsh list --state-running --name | grep "$GUEST_NAME" -c > /dev/null
        then
            set +e
            virsh start "$GUEST_NAME"
            set -e
            # even though the server should be able to handle starting all vms
            # at once, we delay it a tiny bit, just because it doesn't matter
            sleep 1
        else
            echo "$GUEST_NAME already up & running, nothing to do for me"
        fi
    done
    echo "All guests in $VM_FOLDER are now started"
else
    echo "\"$VM_FOLDER\" doesn't exist"
fi
