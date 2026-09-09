#!/bin/bash

set -euo pipefail

module load modules modules-init modules-gs
module load bcftools/1.21 htslib/1.21 rtg-tools/3.12.1

tech="pacbio"
tool="mitorsaw"
group="_025"

INDIR="/net/nwgc/vol1/home/czaka/analysis/${tool}/smaht/hapmap_0.2.14/${tech}"
SAMPLES=$(cut -d',' -f 1 ${INDIR}/samples.csv | tail +2)

REF="/net/nwgc/vol1/home/czaka/tools/mitoscope/resources/MT.fasta"
REF_RTG="/net/nwgc/vol1/home/czaka/analysis/mitoscope/smaht/hapmap/hprc_truthset_eval/rtg_mt_ref"
HPRC_FORMATTED_VCF="/net/nwgc/vol1/home/czaka/analysis/mitoscope/smaht/hapmap/hprc_truthset_eval/hprc-v2.0-mc-grch38.wave.vcfeval.vcf.gz"
RTG_OUTDIR="/net/nwgc/vol1/home/czaka/analysis/mitoscope/smaht/hapmap/hprc_truthset_eval/${tool}_0.2.14/${tech}${group}/"

## run eval individually per sample (not on merged vcf)
for SAMPLE in ${SAMPLES};
do
    INPUT_VCF="${INDIR}/output${group}/${SAMPLE}/${SAMPLE}.mitorsaw.vcf.gz"
    FORMATTED_VCF="${INDIR}/output${group}/${SAMPLE}/${SAMPLE}.mitorsaw.vcfeval.vcf.gz"

    ## format the input vcf for use with vcfeval
    bcftools norm --multiallelics -both ${INPUT_VCF} | bcftools norm --atomize --atom-overlaps . | \
    bcftools annotate -x FORMAT | \
    bcftools +setGT -- -t a -n c:'1' | \
    sed 's/chrM/MT/g' | bgzip > ${FORMATTED_VCF}
    bcftools index --tbi ${FORMATTED_VCF}

    ## run rtg vcfeval 
    #rtg format -o ${REF_RTG} ${REF}
    rtg vcfeval \
        -b ${HPRC_FORMATTED_VCF}  \
        -c ${FORMATTED_VCF} \
        -t ${REF_RTG} \
        -o ${RTG_OUTDIR}/${SAMPLE}

done

