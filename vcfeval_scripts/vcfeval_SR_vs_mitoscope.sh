#!/bin/bash

set -euo pipefail

module load modules modules-init modules-gs
module load bcftools/1.21 htslib/1.21 rtg-tools/3.12.1

tech="ont"
tool="mitoscope"
SAMPLES=$(cut -d',' -f 1 /net/nwgc/vol1/nobackup/czaka/mitoscope/smaht/hapmap/${tech}/samples.csv)

REF="/net/nwgc/vol1/home/czaka/tools/mitoscope/nextflow/pipeline/resources/MT.fasta"
REF_RTG="/net/nwgc/vol1/nobackup/czaka/mitoscope/smaht/hapmap/hprc_truthset_eval/rtg_mt_ref"

SR_VCF="/net/nwgc/vol1/nobackup/czaka/mutect2/smaht/illumina/output/merged.mutect2.vcfeval.highconf.vcf.gz"

BALDUR_VCF="/net/nwgc/vol1/nobackup/czaka/mitoscope/smaht/hapmap/${tech}/output/merged.baldur.vcf.gz"
BALDUR_FORMATTED_VCF="/net/nwgc/vol1/nobackup/czaka/mitoscope/smaht/hapmap/${tech}/output/merged.baldur.vcfeval.vcf.gz"
BALDUR_FORMATTED_VCF_HIGHCONF="/net/nwgc/vol1/nobackup/czaka/mitoscope/smaht/hapmap/${tech}/output/merged.baldur.vcfeval.highconf.vcf.gz"

RTG_OUTDIR="/net/nwgc/vol1/nobackup/czaka/mitoscope/smaht/hapmap/hprc_truthset_eval/vs_SR/${tool}/${tech}/vcfeval_result_all"
RTG_OUTDIR_HIGHCONF="/net/nwgc/vol1/nobackup/czaka/mitoscope/smaht/hapmap/hprc_truthset_eval/vs_SR/${tool}/${tech}/vcfeval_result_highconf"


## run rtg vcfeval 
#rtg format -o ${REF_RTG} ${REF}
rtg vcfeval \
    -b ${SR_VCF}  \
    -c ${BALDUR_FORMATTED_VCF} \
    -t ${REF_RTG} \
    -o ${RTG_OUTDIR}

rtg vcfeval \
    -b ${SR_VCF}  \
    -c ${BALDUR_FORMATTED_VCF_HIGHCONF} \
    -t ${REF_RTG} \
    -o ${RTG_OUTDIR_HIGHCONF}


## run eval individually per sample (not on merged vcf)
for SAMPLE in ${SAMPLES};
do
    echo ${SAMPLE}
    INPUT_VCF="/net/nwgc/vol1/nobackup/czaka/${tool}/smaht/hapmap/${tech}/output/${SAMPLE}/variants/baldur/${SAMPLE}.MT.filtered.baldur.norm.vcf.gz"
    FORMATTED_VCF="/net/nwgc/vol1/nobackup/czaka/${tool}/smaht/hapmap/${tech}/output/${SAMPLE}/variants/baldur/${SAMPLE}.MT.filtered.baldur.norm.vcfeval.vcf.gz"
    RTG_OUTDIR="/net/nwgc/vol1/nobackup/czaka/mitoscope/smaht/hapmap/hprc_truthset_eval/vs_SR/${tool}/${tech}/individual_samples/${SAMPLE}"

    ## run rtg vcfeval 
    #rtg format -o ${REF_RTG} ${REF}
    rtg vcfeval \
        -b ${SR_VCF}  \
        -c ${FORMATTED_VCF} \
        -t ${REF_RTG} \
        -o ${RTG_OUTDIR}

done



