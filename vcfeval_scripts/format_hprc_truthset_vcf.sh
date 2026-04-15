#!/bin/bash

set -euo pipefail

module load modules modules-init modules-gs
module load bcftools/1.21 htslib/1.21 rtg-tools/3.12.1

HPRC_INPUT_VCF="/net/nwgc/vol1/home/czaka/analysis/mitoscope/smaht/hapmap/hprc_truthset_eval/hprc-v2.0-mc-grch38.wave.vcf.gz"
HPRC_FORMATTED_VCF="/net/nwgc/vol1/home/czaka/analysis/mitoscope/smaht/hapmap/hprc_truthset_eval/hprc-v2.0-mc-grch38.wave.vcfeval.vcf.gz"

# format the hprc truth vcf and select only mt variants in hapmap samples
bcftools view -r chrM ${HPRC_INPUT_VCF} -e 'POS=3106' | \
bcftools norm --multiallelics -both  | \
bcftools norm --atomize --atom-overlaps . | \
bcftools view -s HG002,HG005,HG00438,HG02257,HG02486,HG02622 | \
bcftools view -i 'INFO/AC>0' | \
bcftools view -s HG002 | bcftools annotate -x FORMAT | \
bcftools +setGT -- -t a -n c:'1' | \
sed 's/chrM/MT/g' | sed 's/HG002/SAMPLE/g' | bgzip > ${HPRC_FORMATTED_VCF}
bcftools index --tbi ${HPRC_FORMATTED_VCF}

