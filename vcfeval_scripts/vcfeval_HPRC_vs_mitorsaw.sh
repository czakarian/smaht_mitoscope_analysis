#!/bin/bash

set -euo pipefail

module load modules modules-init modules-gs
module load bcftools/1.21 htslib/1.21 rtg-tools/3.12.1

tech="pacbio"
tool="mitorsaw"

INDIR="/net/nwgc/vol1/home/czaka/analysis/${tool}/smaht/hapmap/${tech}"
SAMPLES=$(cut -d',' -f 1 ${INDIR}/samples.csv | tail +2)
MULTISAMPLE_VCF="${INDIR}/output/merged.${tool}.vcf.gz"
MULTISAMPLE_FORMATTED_VCF="${INDIR}/output/merged.${tool}.vcfeval.vcf.gz"

REF="/net/nwgc/vol1/home/czaka/tools/mitoscope/resources/MT.fasta"
REF_RTG="/net/nwgc/vol1/home/czaka/analysis/mitoscope/smaht/hapmap/hprc_truthset_eval/rtg_mt_ref"
HPRC_FORMATTED_VCF="/net/nwgc/vol1/home/czaka/analysis/mitoscope/smaht/hapmap/hprc_truthset_eval/hprc-v2.0-mc-grch38.wave.vcfeval.vcf.gz"
RTG_OUTDIR="/net/nwgc/vol1/home/czaka/analysis/mitoscope/smaht/hapmap/hprc_truthset_eval/${tool}/${tech}/"

## get first SAMPLE name to reduce to 1 column and replace name
FIRST_SAMPLE=$(bcftools query -l ${MULTISAMPLE_VCF} | head -n 1)
## format the merged multisample vcf for use with vcfeval
bcftools norm --multiallelics -both ${MULTISAMPLE_VCF} | bcftools norm --atomize --atom-overlaps . | \
bcftools +setGT -- -t q -n c:'1' -i 'FMT/DP!="."' | \
bcftools +setGT -- -t q -n c:'0' -i 'FMT/DP=="."' | \
bcftools +setGT -- -t q -n . -i 'FMT/DP=="."' | \
bcftools +fill-tags -- -t 'NUM_AC:1=AC' | \
bcftools +fill-tags -- -t 'AVG_HET:1=sum(VAF)/INFO/NUM_AC' | \
bcftools view -s ${FIRST_SAMPLE}  | \
bcftools annotate -x FORMAT,INFO/AC,INFO/AN | \
bcftools +setGT -- -t a -n c:'1' | \
sed 's/chrM/MT/g' | sed "s/${FIRST_SAMPLE}/SAMPLE/g" | bgzip > ${MULTISAMPLE_FORMATTED_VCF}
bcftools index --tbi ${MULTISAMPLE_FORMATTED_VCF}

## run eval individually per sample (not on merged vcf)
for SAMPLE in ${SAMPLES};
do
    INPUT_VCF="${INDIR}/output/${SAMPLE}/${SAMPLE}.mitorsaw.vcf.gz"
    FORMATTED_VCF="${INDIR}/output/${SAMPLE}/${SAMPLE}.mitorsaw.vcfeval.vcf.gz"

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

