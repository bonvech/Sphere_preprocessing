#!/bin/bash
fff=trigger_TGLTHR
out=$fff.dat

[ -e $out ] && rm $out && echo "previous file $out deleted"
echo $0
cat $fff.head >> $out

#for f in ./test_dbg/*.dbg
for f in ../all.dbg/*.dbg
do
    echo $f 
    awk -f $fff.awk $f >> $out
done
