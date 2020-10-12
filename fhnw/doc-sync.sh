#! /bin/bash

for i in "$@"
do
case $i in
    -d=*|--directories-file=*)
    DIRECTORIES="${i#*=}"
    shift # past argument=value
    ;;
    -t=*|--target=*)
    TARGET="${i#*=}"
    shift # past argument=value
    ;;
    *)
          # unknown option
    ;;
esac
done

if [ -z "$DIRECTORIES" ] || [ ! -f "$DIRECTORIES" ]
then
  echo "No directories provided"
  exit 1
else
  directory_list=$(cat $DIRECTORIES)
  # echo "Synching folders: $directory_list"
fi

if [ -z "$TARGET" ]
then
  echo "No target provided"
  exit 1
else
  echo "Syncing to $TARGET"
fi

# get file with module directories, from a text file, -d/--directories parameter


# first make sure the NFS share is mounted
mount -a

if [ ! -d "$TARGET" ]
then
  echo "Target doesn't exist"
  exit 1
fi

# connect to the VPN, using the password file
openconnect -b --user="<firstname.lastname>@students.fhnw.ch" vpn.fhnw.ch < /<file_with_vpn_password>

# mount fhnw-share
mount -t cifs //fs.edu.ds.fhnw.ch/data/HT /mnt/fhnw-share -o credentials=<file_with_cifs_credentials>

# rsync a list of folders defined above
OLDIFS=$IFS
IFS=';'
while read dest source
do
  echo "synching $dest to $source"
  echo rsync -rltD "/mnt/fhnw-share/$source/" "/mnt/fhnw/$dest"
  rsync -rltD --exclude=".[!.]*" "/mnt/fhnw-share/$source/" "/mnt/fhnw/$dest"
done <<< "$directory_list"
IFS=$OLDIFS

# unmount share & kill vpn
umount /mnt/fhnw-share
pkill -SIGINT openconnect
