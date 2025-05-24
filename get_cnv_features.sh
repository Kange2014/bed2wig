#!/bin/bash

type=InOut
dir=${type}_map/ichorCNA
output=v0_wgs_${type}_ichorCNA_features.tsv

if [ -s $output ]; then rm $output; fi

for i in `ls $dir/`
do
    sample=$dir/$i/$i.correctedDepth.txt
    id=$(echo ${i/_${type}_nucl_map.bed/})
    if [ ! -s $output ]; then
        echo -ne "sample_id\t" > $output
        sed '1d' $sample | awk -v OFS='\t' '{print $1"_"$2"_"$3}' | tr '\n' '\t' | paste -s >> $output
        #echo -e "\n" >> $output
    fi  
    echo -ne $id"\t" >> $output
    sed '1d' $sample | cut -f 4 | tr '\n' '\t' | paste -s >> $output
    # echo -e "\n" >> $output
done
