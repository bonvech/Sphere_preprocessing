#!/bin/bash
fff=high_code
fff=all_dbg_params
out=$fff.dat

[ -e $out ] && rm $out && echo "previous file $out deleted"
echo $0
cat $fff.head >> $out

for f in ./*.dbg
#for f in ./*.dbg
do
    echo $f 
    awk -f $fff.awk $f >> $out
done
