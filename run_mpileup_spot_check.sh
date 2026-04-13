#!/bin/bash

module load modules modules-init modules-gs 
module load samtools/1.21

export SAMPLE_FILE="/net/nwgc/vol1/home/czaka/analysis/mutect2/smaht/illumina/hapmap/samples.csv"
export OUTDIR="/net/nwgc/vol1/home/czaka/analysis/mitoscope/smaht/analysis/pileup_bases"
export ref="/net/nwgc/vol2/nobackup/nocleanup/smaht/reference/SMAFI23ELK2A.fa"


awk -F ',' 'NR > 1 {print $1,$2}' ${SAMPLE_FILE} | while read -r SAMPLE FILE
do
    echo $SAMPLE

    positions="8860 4769"
    for pos in $positions;
    do
        echo $pos
        samtools mpileup -Q 0 -q 0 --ff 0 --reference ${ref} --max-depth 0 --no-output-ends --no-output-ins --no-output-ins --no-output-del --no-output-del -r chrM:${pos}-${pos} ${FILE} | cut -f 5 | fold -w1 | sort | uniq -c | sed 's/^ *//' > ${OUTDIR}/${SAMPLE}.${pos}.base_comp.txt
    done

done

# export SAMPLE_FILE="/net/nwgc/vol1/home/czaka/analysis/mitoscope/smaht/hapmap/pacbio/samples.csv"
# export OUTDIR="/net/nwgc/vol1/home/czaka/analysis/mitoscope/smaht/analysis/pileup_bases"

# awk -F ',' '{print $1}' ${SAMPLE_FILE} | while read -r SAMPLE
# do
#     echo $SAMPLE
#     FILE="/net/nwgc/vol1/home/czaka/analysis/mitoscope/smaht/hapmap/pacbio/output/${SAMPLE}/alignments/${SAMPLE}.mt.bam"

#     positions="8860 4769"
#     for pos in $positions;
#     do
#         echo $pos
#         samtools mpileup --no-output-ends --no-output-ins --no-output-ins --no-output-del --no-output-del -r MT:${pos}-${pos} ${FILE} | cut -f 5 | fold -w1 | sort | uniq -c | sed 's/^ *//' > ${OUTDIR}/${SAMPLE}.${pos}.base_comp.txt
#     done

# done


# export SAMPLE_FILE="/net/nwgc/vol1/home/czaka/analysis/mutect2/smaht/illumina/benchmark/samples_full.csv"
# export OUTDIR="/net/nwgc/vol1/home/czaka/analysis/mitoscope/smaht/analysis/pileup_bases"
# export ref="/net/nwgc/vol2/nobackup/nocleanup/smaht/reference/SMAFI23ELK2A.fa"

# awk -F ',' '{print $1,$2}' ${SAMPLE_FILE} | while read -r SAMPLE FILE
# do
#     echo $SAMPLE

#     positions="66"
#     for pos in $positions;
#     do
#         echo $pos
#         samtools mpileup --reference ${ref} --no-output-ends --no-output-ins --no-output-ins --no-output-del --no-output-del -r chrM:${pos}-${pos} ${FILE} | cut -f 5 | fold -w1 | sort | uniq -c | sed 's/^ *//' > ${OUTDIR}/benchmark/${SAMPLE}.${pos}.base_comp.txt
#     done

# done


# export SAMPLE_FILE="/net/nwgc/vol1/home/czaka/analysis/mitoscope/smaht/benchmark/ont/samples.csv"
# export OUTDIR="/net/nwgc/vol1/home/czaka/analysis/mitoscope/smaht/analysis/pileup_bases/"

# awk -F ',' '{print $1}' ${SAMPLE_FILE} | while read -r SAMPLE
# do
#     echo $SAMPLE
#     FILE="/net/nwgc/vol1/home/czaka/analysis/mitoscope/smaht/benchmark/ont/output/${SAMPLE}/alignments/${SAMPLE}.mt.bam"

#     positions="66"
#     for pos in $positions;
#     do
#         echo $pos
#         samtools mpileup --max-depth 0 --no-output-ends --no-output-ins --no-output-ins --no-output-del --no-output-del -r MT:${pos}-${pos} ${FILE} | cut -f 5 | fold -w1 | sort | uniq -c | sed 's/^ *//' > ${OUTDIR}/benchmark/${SAMPLE}.${pos}.base_comp.txt
#     done

# done
