#!/bin/bash

set -euo pipefail

module load modules modules-init modules-gs
module load bcftools/1.21 htslib/1.21 rtg-tools/3.12.1

tech="pacbio"
tool="himito"
SAMPLES=$(cut -d',' -f 1 /net/nwgc/vol1/nobackup/czaka/himito/smaht/hapmap/${tech}/samples.csv | tail +2)

REF="/net/nwgc/vol1/home/czaka/tools/mitoscope/nextflow/pipeline/resources/MT.fasta"
REF_RTG="/net/nwgc/vol1/nobackup/czaka/mitoscope/smaht/hapmap/hprc_truthset_eval/rtg_mt_ref"

SR_VCF="/net/nwgc/vol1/nobackup/czaka/mutect2/smaht/illumina/output/merged.mutect2.vcfeval.highconf.vcf.gz"

MULTISAMPLE_VCF="/net/nwgc/vol1/nobackup/czaka/${tool}/smaht/hapmap/${tech}/output/merged.himito.vcf.gz"
MULTISAMPLE_FORMATTED_VCF="/net/nwgc/vol1/nobackup/czaka/${tool}/smaht/hapmap/${tech}/output/merged.himito.vcfeval.vcf.gz"
MULTISAMPLE_FORMATTED_VCF_HIGHCONF="/net/nwgc/vol1/nobackup/czaka/${tool}/smaht/hapmap/${tech}/output/merged.himito.vcfeval.highconf.vcf.gz"

RTG_OUTDIR="/net/nwgc/vol1/nobackup/czaka/mitoscope/smaht/hapmap/hprc_truthset_eval/vs_SR/${tool}/${tech}/vcfeval_result_all"
RTG_OUTDIR_HIGHCONF="/net/nwgc/vol1/nobackup/czaka/mitoscope/smaht/hapmap/hprc_truthset_eval/vs_SR/${tool}/${tech}/vcfeval_result_highconf"


## run rtg vcfeval 
#rtg format -o ${REF_RTG} ${REF}
rtg vcfeval \
    -b ${SR_VCF}  \
    -c ${MULTISAMPLE_FORMATTED_VCF} \
    -t ${REF_RTG} \
    -o ${RTG_OUTDIR}

rtg vcfeval \
    -b ${SR_VCF}  \
    -c ${MULTISAMPLE_FORMATTED_VCF_HIGHCONF} \
    -t ${REF_RTG} \
    -o ${RTG_OUTDIR_HIGHCONF}


## run eval individually per sample (not on merged vcf)
for SAMPLE in ${SAMPLES};
do
    echo ${SAMPLE}
    INPUT_VCF="/net/nwgc/vol1/nobackup/czaka/${tool}/smaht/hapmap/${tech}/output/${SAMPLE}/${SAMPLE}.vcf.gz"
    FORMATTED_VCF="/net/nwgc/vol1/nobackup/czaka/${tool}/smaht/hapmap/${tech}/output/${SAMPLE}/${SAMPLE}.vcfeval.vcf.gz"
    RTG_OUTDIR="/net/nwgc/vol1/nobackup/czaka/mitoscope/smaht/hapmap/hprc_truthset_eval/vs_SR/${tool}/${tech}/individual_samples/${SAMPLE}"

    ## run rtg vcfeval 
    #rtg format -o ${REF_RTG} ${REF}
    rtg vcfeval \
        -b ${SR_VCF}  \
        -c ${FORMATTED_VCF} \
        -t ${REF_RTG} \
        -o ${RTG_OUTDIR}

done



