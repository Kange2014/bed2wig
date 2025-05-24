#!/bin/bash

bin_size=1000000

if [ $bin_size -eq 1000000 ]; then
	bin_size_short=1000kb
fi

if [ $bin_size -eq 500000 ]; then
	bin_size_short=500kb
fi

if [ $bin_size -eq 100000 ]; then
	bin_size_short=100kb
fi

if [ $bin_size -eq 50000 ]; then
	bin_size_short=50kb
fi

if [ $bin_size -eq 10000 ]; then
	bin_size_short=10kb
fi

#project_id=NH_WGBS_001_90G_60_2022-04-02
#project_id=NH_WGBS_002_90G_144_2022-07-05
#project_id=NH_WGBS_003_90G_174_2022-07-18
#project_id=Paper_WGBS_ZJU_90G_60_2022-08-28
#project_id=NH_WGBS_004_90G_82_2022-10-10


type=InOut
assembly_results=${type}_map/ichorcna.${bin_size_short}.results.txt

if [ -e $assembly_results ]; then rm $assembly_results; fi

echo -e "Sample\tTumor_Fraction\tTumor_Ploidy\tMAPD" > $assembly_results

dir=${type}_map/ichorCNA

for sample in `ls $dir`
do
		id=$(echo ${sample/_${type}_nucl_map.bed/})
		result_path=$dir/$sample
		if [ ! -d "$result_path" ]; then continue; fi
		
		if [ $sample = "wigs" ]; then continue; fi
		
		result_file=$result_path/${sample}.params.txt
		if [ ! -s $result_file ]; then 
			echo $result_file " not exists or is empty."
			continue
		fi
		
		tf=$(awk 'NR>2{print $0}' $result_file | grep "Tumor Fraction" | cut -d":" -f 2 | cut -f 2)
		ploidy=$(awk 'NR>2{print $0}' $result_file | grep "Ploidy" | cut -d":" -f 2 | cut -f 2)
		mapd=$(awk 'NR>2{print $0}' $result_file | grep "GC-Map" | cut -d":" -f 2 | cut -f 2)
		
		echo -e $id"\t"$tf"\t"$ploidy"\t"$mapd >> $assembly_results

done
