#!/bin/bash

genome=/data00/home/zhenglulu.01/mnt/fragmentomics_diving/hg19.genome

dir=/mnt/share-bytenas-hl-mix/home/zhenglulu.01/v0_wgs/v0_nucleosome_distance

for i in `ls $dir/*_core.bed`
do
   id=`echo ${i/_core.bed/.bed/}`
   grep -P '^[0-9X-Y]{1,2}\t' $i | sort -k1,1 -k2,2n --parallel=8 | awk -v OFS='\t' '{print $1,$2,$3,1}' > $i.tmp
   sbatch -p All --wrap "perl bed2wig.pl --bedgraph $i.tmp --genomeSize $genome --wig $i.wig --step 1000000" 
   #break
done
