#!/bin/bash
name=all_dbg_params
er=$name.dat
awkfile=$name.awk

[ -e $er ] && rm $er && echo "previous file $er deleted"

for f in *
do
    [[ "$f" != *.dbg ]] && continue
    echo $f 
    echo >> $er
    echo >> $er
    echo "FLIGHT ">> $er
    echo $f >> $er
    echo >> $er
#    cat $f |grep { "THR" || "File" }  >> $er
#    cat $f |grep -f pathigh  >> $er
    awk -f $awkfile $f >> $er
    echo >> $er
done

