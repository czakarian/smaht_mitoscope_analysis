#!/bin/bash

set -euo pipefail

source /etc/profile.d/modules.sh
module load modules modules-init modules-gs 
module load bcftools/1.21 htslib/1.21

INDIR="/net/nwgc/vol1/home/czaka/analysis/mitoscope/smaht/hapmap/hprc_truthset_eval/"
TABLE_BY_SAMPLE="/net/nwgc/vol1/home/czaka/analysis/mitoscope/smaht/benchmark_analysis/vcfeval_scripts/vcfeval_table_mitoscope_snvs.csv"

## tables by sample
SNV_OUT_BY_SAMPLE="${INDIR}/mitoscope_vaf_comparison/HPRC.vcfeval.by_sample.snvs.tsv"

HEADER_BY_SAMPLE="tool\tcategory\ttech\tsample\ttrue_positives_baseline\tfalse_positives\ttrue_positives_call\tfalse_negatives\tprecision\tsensitivity\tf_measure"

echo -e ${HEADER_BY_SAMPLE} > ${SNV_OUT_BY_SAMPLE}

awk -F',' 'NR > 1 {print $1, $2, $3, $4}' ${TABLE_BY_SAMPLE} | while read -r tool category tech sample
do

    x=$(zcat ${INDIR}/mitoscope_snv_bench/${tool}_${category}/${tech}/${sample}/snp_roc.tsv.gz | grep -v '^#' | cut -f 2- || true)
    echo -e "${tool}\t${category}\t${tech}\t${sample}\t${x}" >> ${SNV_OUT_BY_SAMPLE}

done