#!/bin/bash

module load modules modules-init modules-gs
module load samtools/1.21 mosdepth/0.3.6

export SAMPLE_MANIFEST="/net/nwgc/vol1/home/czaka/analysis/mutect2/smaht/illumina/hapmap/samples.csv"
export OUTDIR="/net/nwgc/vol1/home/czaka/analysis/mitoscope/smaht/analysis/short_read_coverage"
export READ_COUNT_OUTDIR="/net/nwgc/vol1/home/czaka/analysis/mitoscope/smaht/analysis/short_read_total_counts"
export REF="/net/nwgc/vol1/home/czaka/ref/smaht/SMAFI23ELK2A.fa"
export NUC_INTERVALS="/net/nwgc/vol1/home/czaka/tools/mitoscope/resources/nuclear_intervals.bed"
export THREADS=16

awk -F ',' 'NR>1 {print $1,$2}' ${SAMPLE_MANIFEST} | while read -r SAMPLE CRAM
do

    echo $SAMPLE
    echo $CRAM

    ## total read pairs (remove suppl/secondary/unmapped?)
    samtools view -f 67 -F 2308 -@ ${THREADS} -c --reference ${REF} ${CRAM} > ${READ_COUNT_OUTDIR}/${SAMPLE}.total_read_count.v2.txt

    # mosdepth ${OUTDIR}/chrM/${SAMPLE} ${CRAM} --fasta ${REF} --chrom chrM --threads ${THREADS} --no-per-base --fast-mode
    # mosdepth ${OUTDIR}/${SAMPLE} ${CRAM} --fasta ${REF} --by ${NUC_INTERVALS} --threads ${THREADS} --no-per-base --fast-mode

done
