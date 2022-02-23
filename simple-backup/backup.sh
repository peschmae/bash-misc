#!/bin/bash

# change this
src=./volumes

# should need changes
dest=/mnt/backup/gitea/
filename=$(date +%Y%m%d%H%M).tar.gz
keep_days=10

# create tarball
tar -pczvf "${filename}" "${src}"

# to ignore the preserve ownership error
cp "${filename}" "${dest}"
rm "${filename}"

# delete outdated backups
find "${dest}" -ctime +$keep_days -type f -iname "*.tar.gz"

echo Backup successful
