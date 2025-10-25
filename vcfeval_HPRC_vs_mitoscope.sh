#!/bin/bash

module load modules modules-init modules-gs
module load bcftools/1.21 htslib/1.21 rtg-tools/3.12.1

tech="pacbio"
tool="mitoscope"
SAMPLES=$(cut -d',' -f 1 /net/nwgc/vol1/nobackup/czaka/mitoscope/smaht/hapmap/${tech}/samples.csv | tail +2)

REF="/net/nwgc/vol1/home/czaka/tools/mitoscope/nextflow/pipeline/resources/MT.fasta"
REF_RTG="/net/nwgc/vol1/nobackup/czaka/mitoscope/smaht/hapmap/hprc_truthset_eval/rtg_mt_ref"

HPRC_INPUT_VCF="/net/nwgc/vol1/nobackup/czaka/mitoscope/smaht/hapmap/hprc_truthset_eval/hprc-v2.0-mc-grch38.wave.vcf.gz"
HPRC_FORMATTED_VCF="/net/nwgc/vol1/nobackup/czaka/mitoscope/smaht/hapmap/hprc_truthset_eval/hprc-v2.0-mc-grch38.wave.vcfeval.vcf.gz"

BALDUR_VCF="/net/nwgc/vol1/nobackup/czaka/mitoscope/smaht/hapmap/${tech}/output/merged.baldur.vcf.gz"
BALDUR_FORMATTED_VCF="/net/nwgc/vol1/nobackup/czaka/mitoscope/smaht/hapmap/${tech}/output/merged.baldur.vcfeval.vcf.gz"
BALDUR_FORMATTED_VCF_HIGHCONF="/net/nwgc/vol1/nobackup/czaka/mitoscope/smaht/hapmap/${tech}/output/merged.baldur.vcfeval.highconf.vcf.gz"

RTG_OUTDIR="/net/nwgc/vol1/nobackup/czaka/mitoscope/smaht/hapmap/hprc_truthset_eval/${tool}/${tech}/vcfeval_result_all"
RTG_OUTDIR_HIGHCONF="/net/nwgc/vol1/nobackup/czaka/mitoscope/smaht/hapmap/hprc_truthset_eval/${tool}/${tech}/vcfeval_result_highconf"

# # format the hprc truth vcf and select only mt variants in hapmap samples
# bcftools view -r chrM ${HPRC_INPUT_VCF} -e 'POS=3106' | \
# bcftools norm --multiallelics -both  | \
# bcftools norm --atomize --atom-overlaps . | \
# bcftools view -s HG002,HG005,HG00438,HG02257,HG02486,HG02622 | \
# bcftools view -i 'INFO/AC>0' | \
# bcftools view -s HG002 | bcftools annotate -x FORMAT | \
# bcftools +setGT -- -t a -n c:'1' | \
# sed 's/chrM/MT/g' | sed 's/HG002/SAMPLE/g' | bgzip > ${HPRC_FORMATTED_VCF}
# bcftools index --tbi ${HPRC_FORMATTED_VCF}

## format the merged baldur vcf for use with vcfeval
bcftools norm --multiallelics -both ${BALDUR_VCF} | bcftools norm --atomize --atom-overlaps . | \
bcftools +fill-tags -- -t 'NUM_AC:1=AC' | \
bcftools view -s hapmap-${tech}-bcm  | \
bcftools annotate -x FORMAT | \
bcftools +setGT -- -t a -n c:'1' | \
sed "s/hapmap-${tech}-bcm/SAMPLE/g" | bgzip > ${BALDUR_FORMATTED_VCF}
bcftools index --tbi ${BALDUR_FORMATTED_VCF}

## high conf variants (in at least 2 sites)
bcftools view -i 'NUM_AC>=2' ${BALDUR_FORMATTED_VCF} -Oz -o ${BALDUR_FORMATTED_VCF_HIGHCONF}
bcftools index --tbi ${BALDUR_FORMATTED_VCF_HIGHCONF}

## run rtg vcfeval 
#rtg format -o ${REF_RTG} ${REF}
rtg vcfeval \
    -b ${HPRC_FORMATTED_VCF}  \
    -c ${BALDUR_FORMATTED_VCF} \
    -t ${REF_RTG} \
    -o ${RTG_OUTDIR}

rtg vcfeval \
    -b ${HPRC_FORMATTED_VCF}  \
    -c ${BALDUR_FORMATTED_VCF_HIGHCONF} \
    -t ${REF_RTG} \
    -o ${RTG_OUTDIR_HIGHCONF}


# ## run eval individually per sample (not on merged vcf)
# for SAMPLE in ${SAMPLES};
# do
#     BALDUR_VCF="/net/nwgc/vol1/nobackup/czaka/mitoscope/smaht/hapmap/${tech}/output/${SAMPLE}/variants/baldur/to_ref/${SAMPLE}.MT.filtered.baldur.norm.vcf.gz"
#     BALDUR_FORMATTED_VCF="/net/nwgc/vol1/nobackup/czaka/mitoscope/smaht/hapmap/${tech}/output/${SAMPLE}/variants/baldur/to_ref/${SAMPLE}.MT.filtered.baldur.norm.vcfeval.vcf.gz"
#     RTG_OUTDIR="/net/nwgc/vol1/nobackup/czaka/mitoscope/smaht/hapmap/hprc_truthset_eval/${tool}/${tech}/individual_samples/${SAMPLE}"

#     ## format the baldur vcf for use with vcfeval
#     bcftools annotate -x FORMAT ${BALDUR_VCF} | \
#     bcftools +setGT -- -t a -n c:'1' | bgzip > ${BALDUR_FORMATTED_VCF}
#     bcftools index --tbi ${BALDUR_FORMATTED_VCF}

#     ## run rtg vcfeval 
#     #rtg format -o ${REF_RTG} ${REF}
#     rtg vcfeval \
#         -b ${HPRC_FORMATTED_VCF}  \
#         -c ${BALDUR_FORMATTED_VCF} \
#         -t ${REF_RTG} \
#         -o ${RTG_OUTDIR}

# done
