#!/bin/bash

#if [ -e "samples.list" ]; then rm samples.list; fi

source ~/miniconda3/etc/profile.d/conda.sh && conda activate r4-base

bin_size=500000

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

meta_gc=~/software/ichorCNA-master/inst/extdata/gc_hg19_${bin_size_short}.wig
meta_map=~software/ichorCNA-master/inst/extdata/map_hg19_${bin_size_short}.wig
meta_centromere=~/software/ichorCNA-master/inst/extdata/GRCh37.p13_centromere_UCSC-gapTable.txt

pon_path=ichorCNA/PoN/$bin_size_short
pon=WGBS_PoN_${bin_size_short}_median_normAutosome_mapScoreFiltered_median.rds

genome=~/hg19.genome

project_id=90G_82_2022-10-10

wig_path=ichorCNA/$project_id/$bin_size_short/wigs
if [ ! -d "$wig_path" ]; then mkdir -p $wig_path;fi

dir=/data/project/WGBS/$project_id/analysis/

for sample in `ls $dir`
do
	echo $sample
	sample_path=$dir/${sample}/bam/${sample}.dedup.bam

	if [ ! -s $sample_path ]; then
		echo ${sample_path}" not exists or is empty."
		continue
	fi

	# Generate Read Count File
	
	if [ ! -s $wig_path/${sample}.wig ]; then
		#job=$(sbatch -p Dev --wrap "readCounter --window $bin_size --quality 20 --chromosome '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,X,Y' $sample_path > $wig_path/${sample}.wig ")
		job=$(sbatch -p Dev --wrap "perl bed2wig.pl --bedgraph ${file}.tmp --genomeSize $genome --wig ${file}.wig --step ${bin_size} ")
    jobid=$(echo $job | cut -d" " -f 4)
		echo $jobid
		#readCounter --window $bin_size --quality 20 --chromosome '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,X,Y' $sample_path > $wig_path/${sample}.wig 
	fi
	
	
	# judge whether the file is written over
	# RES=$(flock -x -n $wig_path/${sample}.wig -c "echo ok")
	# if [ "$RES" = "ok" ];then
	
	result_path=ichorCNA/$project_id/$bin_size_short/$sample
	if [ ! -d "$result_path" ]; then mkdir -p $result_path;fi
	
	#Run ichorCNA for tissue samples
	#
	# set genomeStyle to Ensembl, due to:
	# 1. default: NCBI will report connection error
	# 2. both of them have same style: no chr string in the name of chromosome
	
	# for tumor adjacent samples which are expected to have low tumor contens,
	# use below parameters according to ichorCNA's recommendations:
	# 
	parameters1="--id $sample \
				--WIG $wig_path/${sample}.wig \
				--ploidy 'c(2,3)' \
				--normal 'c(0.2, 0.35, 0.5, 0.65, 0.8, 0.95, 0.99, 0.995, 0.999)' \
				--maxCN 5 \
				--gcWig $meta_gc \
				--mapWig $meta_map \
				--centromere $meta_centromere \
				--normalPanel $pon_path/$pon \
				--genomeStyle 'Ensembl' \
				--includeHOMD False \
				--chrs 'c(1:22)' \
				--chrTrain 'c(1:22)' \
				--estimateNormal True \
				--estimatePloidy True \
				--estimateScPrevalence false \
				--scStates 'c()' \
				--txnE 0.9999 --txnStrength 10000 \
				--outDir $result_path"
	
	# for tumor samples, use below parameters according to ichorCNA's recommendations:
	parameters2="--id $sample \
				--WIG $wig_path/${sample}.wig \
				--ploidy 'c(2,3)' \
				--normal 'c(0.2, 0.35, 0.5, 0.65, 0.8, 0.95, 0.99, 0.995, 0.999)' \
				--maxCN 5 \
				--gcWig $meta_gc \
				--mapWig $meta_map \
				--centromere $meta_centromere \
				--normalPanel $pon_path/$pon \
				--genomeStyle 'Ensembl' \
				--includeHOMD False \
				--chrs 'c(1:22, \"X\")' \
				--chrTrain 'c(1:22)' \
				--estimateNormal True \
				--estimatePloidy True \
				--estimateScPrevalence True \
				--scStates 'c(0,3)' \
				--txnE 0.9999 --txnStrength 10000 \
				--outDir $result_path"

	# wo do not know the tumor contents, probably from 0 to 90%
	if [ ! -s $result_path/${sample}.params.txt ]; then
			# Rscript /data00/home/zhenglulu.01/software/ichorCNA-master/scripts/runIchorCNA.R $parameters2
			if [ ! -s $wig_path/${sample}.wig ]; then
				sbatch -p Dev --dependency=afterany:${jobid} --wrap " Rscript /data00/home/zhenglulu.01/software/ichorCNA-master/scripts/runIchorCNA.R $parameters2 "
			else
				sbatch -p Dev --wrap " Rscript /data00/home/zhenglulu.01/software/ichorCNA-master/scripts/runIchorCNA.R $parameters2 "
			fi
	fi
	
done
