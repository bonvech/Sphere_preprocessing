#!/bin/bash
name=all_dbg_params
er=$name.dat
awkfile=$name.awk

for f in *
do
    [[ "$f" != *.dbg ]] && continue

    echo $f 
    out=$f".dat"
    awk -f $awkfile $f >> $out
done

