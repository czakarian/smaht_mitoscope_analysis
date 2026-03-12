#!/bin/bash

source /etc/profile.d/modules.sh
module load modules modules-init modules-gs 
module load bcftools/1.21 htslib/1.21

tech="pacbio"
group="benchmark"

OUTDIR="/net/nwgc/vol1/nobackup/czaka/mitoscope/smaht/${group}/${tech}/output"
SCRIPTDIR="/net/nwgc/vol1/home/czaka/tools/mitoscope/bin/"
MITOMAP="/net/nwgc/vol1/home/czaka/tools/mitoscope/resources/annotations/CombinedDiseaseVariantDB.csv"

# ## mutserve
# LIST_OF_VCFS=$(ls ${OUTDIR}/*/variants/mutserve/to_ref/*.mutserve.norm.vcf.gz)
# bcftools merge -m none ${LIST_OF_VCFS} -Oz -o ${OUTDIR}/merged.mutserve.vcf.gz

# ${SCRIPTDIR}/annotate.py --annotations ${MITOMAP} \
# --input ${OUTDIR}/merged.mutserve.vcf.gz --caller mutserve --multisample

## baldur
LIST_OF_VCFS=$(ls ${OUTDIR}/*/variants/baldur/*.mt.baldur.annotated.vcf.gz)
bcftools merge -m none ${LIST_OF_VCFS} -Oz -o ${OUTDIR}/merged.mt.baldur.annotated.vcf.gz

${SCRIPTDIR}/annotate.py --annotations ${MITOMAP} \
--input ${OUTDIR}/merged.mt.baldur.annotated.vcf.gz --caller baldur --multisample


# LIST_OF_VCFS=$(ls /net/nwgc/vol1/nobackup/czaka/himito/smaht/hapmap/ont/output/*/*.vcf.gz)
# bcftools merge -m none ${LIST_OF_VCFS} -Oz -o /net/nwgc/vol1/nobackup/czaka/himito/smaht/hapmap/ont/output/merged.himito.vcf.gz

