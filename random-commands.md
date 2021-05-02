# Random commands

## Smartctl show bytes written in TB (e.g. for SSD lifetime)
```
smartctl -A /dev/sda | awk '/^241/ { print "TWBW: " ($10 *512 ) * 1.0e-12, "TB" } '
```

## Convert raw qemu volume to qcow2
```
qemu-img convert -f raw -O qcow2 /var/lib/libvirt/storage-pool/<VOL_NAME>.img /var/lib/libvirt/storage-pool/<VOL_NAME>.qcow2
```

## MegaCLI shizzle

_List controllers_
```
/opt/MegaRAID/MegaCli/MegaCli64 -AdpAllInfo -aALL
```
_Show controller config_
```
/opt/MegaRAID/MegaCli/MegaCli64 -CfgDsply -aALL
```
_Show physical drives_
```
/opt/MegaRAID/MegaCli/MegaCli64 -PDList -aALL
/opt/MegaRAID/MegaCli/MegaCli64 -PDInfo -PhysDrv [E:S] -aALL
```
More Stuff: http://erikimh.com/megacli-cheatsheet/

### rdiff Backup
```
/root/rdiff-backup/bin/rdiff-backup -v 5 --print-statistics --remote-schema "ssh -C -p 22 %s /<path-to-rdiff-env>/rdiff-env/bin/rdiff-backup --server" --exclude-globbing-filelist /root/syno-excludelist  <user>@<host>::"/volume1/ebooks" /backup/ebooks/ | /usr/bin/logger -t rdiff-backup
```