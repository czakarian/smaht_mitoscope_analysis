#!/bin/bash

module load modules modules-init modules-gs
module load samtools/1.21

export SAMPLE_MANIFEST="/net/nwgc/vol1/home/czaka/analysis/mitoscope/smaht/hapmap/pacbio/samples.csv"
export OUTDIR="/net/nwgc/vol1/home/czaka/analysis/mitoscope/smaht/analysis/read_lengths_full_bams"
export REF="/net/nwgc/vol1/home/czaka/ref/smaht/SMAFI23ELK2A.fa"
export THREADS=16

awk -F ',' '{print $1,$2}' ${SAMPLE_MANIFEST} | while read -r SAMPLE BAM
do
    ## total counts with removed suppl,secondary,unmapped
    ## samtools view -F 2308 -@ ${THREADS} -c ${BAM} > ${SAMPLE}.total_read_count.txt
    echo $SAMPLE
    echo $BAM
    ## remove suppl,secondary,unmapped
    samtools view --reference ${REF} -F 2308 -@ ${THREADS} ${BAM} | awk '{print length($10)}' > ${OUTDIR}/${SAMPLE}.read_lengths.txt
done