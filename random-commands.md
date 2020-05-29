# Random commands

## Smartctl show bytes written in TB (e.g. for SSD lifetime)
```
smartctl -A /dev/sda | awk '/^241/ { print "TWBW: " ($10 *512 ) * 1.0e-12, "TB" } '
```
