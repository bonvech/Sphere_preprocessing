#!/bin/bash
fff=current_hv_code_everymin
out=$fff.dat

[ -e $out ] && rm $out && echo "previous file $out deleted"
echo $0
cat $fff.head >> $out

for f in ./all.dbg/*.dbg
#for f in ./*.dbg
do
    echo $f 
    awk -f $fff.awk $f >> $out
done
