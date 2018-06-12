#!/bin/bash
# get BW

while getopts "w:c:" OPTION
do
     case $OPTION in
        w)
          warn=$OPTARG
          ;;
        c)
          crit=$OPTARG
          ;;
      esac
done


i=$(vnstat --oneline | awk -F\; '{ print $11 }')
bw=$(echo $i | awk '{ print $1 }')
unit=$(echo $i | awk '{ print $2 }')
case "$unit" in
KiB)    bw_GB=$(echo "$bw/1024/1024" | bc -l)
    ;;
MiB)    bw_GB=$(echo "$bw/1024" | bc -l)
    ;;
GiB)     bw_GB=$bw
    ;;
TiB)    bw_GB=$(echo "$bw*1024" | bc -l)
    ;;
esac

bw_GB_int=${bw_GB%.*}
GB=1000
crit_GB=$((crit*GB))
warn_GB=$((warn*GB))

if  [ $bw_GB_int -lt $warn_GB ]
then
    echo "OK - bandwidth Consumed is "$bw_GB" GB"
    exit 0
elif  [[ ( $bw_GB_int -ge $warn_GB ) && ( $bw_GB_int -lt $crit_GB ) ]]
then
    echo "WARNING - Bandwidth Consumed is "$bw_GB" GB"
    exit 1
elif  [ $bw_GB_int -ge $crit_GB ]
then
    echo "CRITICAL- Bandwidth Consumed is "$bw_GB" GB"
    exit 2
else  
    echo "OK - Bandwoidth Conusmed is "$bw_GB" GB"
    exit 0
fi
