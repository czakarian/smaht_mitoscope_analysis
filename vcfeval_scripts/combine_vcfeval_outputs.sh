#!/bin/bash

set -euo pipefail

source /etc/profile.d/modules.sh
module load modules modules-init modules-gs 
module load bcftools/1.21 htslib/1.21

INDIR="/net/nwgc/vol1/home/czaka/analysis/mitoscope/smaht/hapmap/hprc_truthset_eval/"
TABLE_BY_SAMPLE="/net/nwgc/vol1/home/czaka/analysis/mitoscope/smaht/benchmark_analysis/vcfeval_scripts/vcfeval_table_by_sample.csv"

## tables by sample
ALL_OUT_BY_SAMPLE="${INDIR}/combined_tables/HPRC.vcfeval.by_sample.all.tsv"
SNV_OUT_BY_SAMPLE="${INDIR}/combined_tables/HPRC.vcfeval.by_sample.snvs.tsv"
INDEL_OUT_BY_SAMPLE="${INDIR}/combined_tables/HPRC.vcfeval.by_sample.indels.tsv"

HEADER="tool\ttech\ttrue_positives_baseline\tfalse_positives\ttrue_positives_call\tfalse_negatives\tprecision\tsensitivity\tf_measure"
HEADER_BY_SAMPLE="tool\ttech\tsample\ttrue_positives_baseline\tfalse_positives\ttrue_positives_call\tfalse_negatives\tprecision\tsensitivity\tf_measure"

echo -e ${HEADER_BY_SAMPLE} > ${ALL_OUT_BY_SAMPLE}
echo -e ${HEADER_BY_SAMPLE} > ${SNV_OUT_BY_SAMPLE}
echo -e ${HEADER_BY_SAMPLE} > ${INDEL_OUT_BY_SAMPLE}


awk -F',' 'NR > 1 {print $1, $2, $3}' ${TABLE_BY_SAMPLE} | while read -r tool tech sample
do
    ## snvs
    x=$(zcat ${INDIR}/${tool}/${tech}/${sample}/snp_roc.tsv.gz | grep -v '^#' | cut -f 2- || true)
    echo -e "${tool}\t${tech}\t${sample}\t${x}" >> ${SNV_OUT_BY_SAMPLE}

    ## indels
    x=$(zcat ${INDIR}/${tool}/${tech}/${sample}/non_snp_roc.tsv.gz | grep -v '^#' | cut -f 2- || true)
    echo -e "${tool}\t${tech}\t${sample}\t${x}" >> ${INDEL_OUT_BY_SAMPLE}

    ## all 
    x=$(zcat ${INDIR}/${tool}/${tech}/${sample}/weighted_roc.tsv.gz | grep -v '^#' | cut -f 2- || true)
    echo -e "${tool}\t${tech}\t${sample}\t${x}" >> ${ALL_OUT_BY_SAMPLE}

done