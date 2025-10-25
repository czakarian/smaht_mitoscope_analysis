#!/bin/bash

source /etc/profile.d/modules.sh
module load modules modules-init modules-gs 
module load bcftools/1.21 htslib/1.21

INDIR="/net/nwgc/vol1/nobackup/czaka/mitoscope/smaht/hapmap/hprc_truthset_eval/"
TABLE="/net/nwgc/vol1/nobackup/czaka/mitoscope/smaht/analysis/vcfeval_table.csv"
TABLE_BY_SAMPLE="/net/nwgc/vol1/nobackup/czaka/mitoscope/smaht/analysis/vcfeval_table_by_sample.csv"

## tables for multisample 
ALL_OUT="/net/nwgc/vol1/nobackup/czaka/mitoscope/smaht/hapmap/hprc_truthset_eval/combined_tables/HPRC.vcfeval.multisample.all.tsv"
SNV_OUT="/net/nwgc/vol1/nobackup/czaka/mitoscope/smaht/hapmap/hprc_truthset_eval/combined_tables/HPRC.vcfeval.multisample.snvs.tsv"
INDEL_OUT="/net/nwgc/vol1/nobackup/czaka/mitoscope/smaht/hapmap/hprc_truthset_eval/combined_tables/HPRC.vcfeval.multisample.indels.tsv"

HC_ALL_OUT="/net/nwgc/vol1/nobackup/czaka/mitoscope/smaht/hapmap/hprc_truthset_eval/combined_tables/HPRC.vcfeval.multisample.all.highconf.tsv"
HC_SNV_OUT="/net/nwgc/vol1/nobackup/czaka/mitoscope/smaht/hapmap/hprc_truthset_eval/combined_tables/HPRC.vcfeval.multisample.snvs.highconf.tsv"
HC_INDEL_OUT="/net/nwgc/vol1/nobackup/czaka/mitoscope/smaht/hapmap/hprc_truthset_eval/combined_tables/HPRC.vcfeval.multisample.indels.highconf.tsv"

## tables by sample
ALL_OUT_BY_SAMPLE="/net/nwgc/vol1/nobackup/czaka/mitoscope/smaht/hapmap/hprc_truthset_eval/combined_tables/HPRC.vcfeval.by_sample.all.tsv"
SNV_OUT_BY_SAMPLE="/net/nwgc/vol1/nobackup/czaka/mitoscope/smaht/hapmap/hprc_truthset_eval/combined_tables/HPRC.vcfeval.by_sample.snvs.tsv"
INDEL_OUT_BY_SAMPLE="/net/nwgc/vol1/nobackup/czaka/mitoscope/smaht/hapmap/hprc_truthset_eval/combined_tables/HPRC.vcfeval.by_sample.indels.tsv"

HEADER="tool\ttech\ttrue_positives_baseline\tfalse_positives\ttrue_positives_call\tfalse_negatives\tprecision\tsensitivity\tf_measure"
HEADER_BY_SAMPLE="tool\ttech\tsample\ttrue_positives_baseline\tfalse_positives\ttrue_positives_call\tfalse_negatives\tprecision\tsensitivity\tf_measure"

echo -e ${HEADER} > ${ALL_OUT}
echo -e ${HEADER} > ${SNV_OUT}
echo -e ${HEADER} > ${INDEL_OUT}
echo -e ${HEADER} > ${HC_ALL_OUT}
echo -e ${HEADER} > ${HC_SNV_OUT}
echo -e ${HEADER} > ${HC_INDEL_OUT}
echo -e ${HEADER_BY_SAMPLE} > ${ALL_OUT_BY_SAMPLE}
echo -e ${HEADER_BY_SAMPLE} > ${SNV_OUT_BY_SAMPLE}
echo -e ${HEADER_BY_SAMPLE} > ${INDEL_OUT_BY_SAMPLE}

## generata table of snp sensitivity, specificity, f1 scores (one for all, one for high confidence)
awk -F',' 'NR > 1 {print $1, $2}' ${TABLE} | while read -r tool tech
do
    ## snvs
    x=$(zcat ${INDIR}/${tool}/${tech}/vcfeval_result_all/snp_roc.tsv.gz | grep -v '^#' | cut -f 2-)
    echo -e "${tool}\t${tech}\t${x}" >> ${SNV_OUT}

    # ## indels
    x=$(zcat ${INDIR}/${tool}/${tech}/vcfeval_result_all/non_snp_roc.tsv.gz | grep -v '^#' | cut -f 2-)
    echo -e "${tool}\t${tech}\t${x}" >> ${INDEL_OUT}

    # ## snvs (high conf)
    x=$(zcat ${INDIR}/${tool}/${tech}/vcfeval_result_highconf/snp_roc.tsv.gz | grep -v '^#' | cut -f 2-)
    echo -e "${tool}\t${tech}\t${x}" >> ${HC_SNV_OUT}

    # ## indels (high conf)
    x=$(zcat ${INDIR}/${tool}/${tech}/vcfeval_result_highconf/non_snp_roc.tsv.gz | grep -v '^#' | cut -f 2-)
    echo -e "${tool}\t${tech}\t${x}" >> ${HC_INDEL_OUT}

    # ## all variants
    x=$(zcat ${INDIR}/${tool}/${tech}/vcfeval_result_highconf/weighted_roc.tsv.gz | grep -v '^#' | cut -f 2-)
    echo -e "${tool}\t${tech}\t${x}" >> ${ALL_OUT}

    # ## all variants (high conf)
    x=$(zcat ${INDIR}/${tool}/${tech}/vcfeval_result_highconf/weighted_roc.tsv.gz | grep -v '^#' | cut -f 2-)
    echo -e "${tool}\t${tech}\t${x}" >> ${HC_ALL_OUT}
done

awk -F',' 'NR > 1 {print $1, $2, $3}' ${TABLE_BY_SAMPLE} | while read -r tool tech sample
do

    ## snvs
    x=$(zcat ${INDIR}/${tool}/${tech}/individual_samples/${sample}/snp_roc.tsv.gz | grep -v '^#' | cut -f 2-)
    echo -e "${tool}\t${tech}\t${sample}\t${x}" >> ${SNV_OUT_BY_SAMPLE}

    ## indels
    x=$(zcat ${INDIR}/${tool}/${tech}/individual_samples/${sample}/non_snp_roc.tsv.gz | grep -v '^#' | cut -f 2-)
    echo -e "${tool}\t${tech}\t${sample}\t${x}" >> ${INDEL_OUT_BY_SAMPLE}

    ## all 
    x=$(zcat ${INDIR}/${tool}/${tech}/individual_samples/${sample}/weighted_roc.tsv.gz | grep -v '^#' | cut -f 2-)
    echo -e "${tool}\t${tech}\t${sample}\t${x}" >> ${ALL_OUT_BY_SAMPLE}


done