#! /bin/bash

cat sizes | while read line 
do
   stringarray=($line)
   echo $(numfmt --from=iec ${stringarray[0]}) 
done