#!/bin/bash

module load modules modules-init modules-gs
module load samtools/1.21

flank=10
GENOME_LEN=16569
MT_REF="/net/nwgc/vol1/home/czaka/tools/mitoscope/resources/MT.fasta"
NUC_REF="/net/nwgc/vol1/home/czaka/ref/GRCh38_no_alt_analysis_set.fasta"

infile="/net/nwgc/vol1/home/czaka/analysis/mitoscope/smaht/analysis/homology_analysis/smaht_benchmarking_tissue_unique_numts.tsv"
flankdir="/net/nwgc/vol1/home/czaka/analysis/mitoscope/smaht/analysis/homology_analysis/numt_flanks"
collapsed_file="/net/nwgc/vol1/home/czaka/analysis/mitoscope/smaht/analysis/homology_analysis/numt_flanks.tsv"

mkdir -p ${flankdir}

export SINGULARITY_BINDPATH="${flankdir}"

echo "header" > ${collapsed_file}

tail +2 ${infile} | while IFS= read -r line; do
    echo $line
    id=$(echo $line | awk '{print $2}')
    nuc_chrom=$(echo $line | awk '{print $3}')
    nuc_pos=$(echo $line | awk '{print $4}')
    mito_start=$(echo $line | awk '{print $6}')
    mito_end=$(echo $line | awk '{print $7}')

    nuc=$(samtools faidx ${NUC_REF} ${nuc_chrom}:$((${nuc_pos} - ${flank}))-$((${nuc_pos} + ${flank})))
    nuc_left=$(samtools faidx ${NUC_REF} ${nuc_chrom}:$((${nuc_pos} - ${flank}))-$((${nuc_pos})))
    nuc_right=$(samtools faidx ${NUC_REF} ${nuc_chrom}:$((${nuc_pos}))-$((${nuc_pos} + ${flank})))
    
    mito_left=$(samtools faidx ${MT_REF} MT:$((${mito_start}))-$((${mito_start} + ${flank})))
    mito_right=$(samtools faidx ${MT_REF} MT:$((${mito_end} - ${flank}))-$((${mito_end})))
    
    echo "nuc:", $nuc
    echo "mito_left:", $mito_left
    echo "mito_right:", $mito_right

    nuc_seq=$(echo $nuc | cut -d " " -f 2)
    mito_left_seq=$(echo $mito_left | cut -d " " -f 2)
    mito_right_seq=$(echo $mito_right | cut -d " " -f 2)

    echo -e ">numt_${id}_nuc\n${nuc_seq}" > ${flankdir}/numt_${id}_nuc.fasta
    echo -e ">numt_${id}_mito_left\n${mito_left_seq}" > ${flankdir}/numt_${id}_mito_left.fasta
    echo -e ">numt_${id}_mito_right\n${mito_right_seq}" > ${flankdir}/numt_${id}_mito_right.fasta

    /net/nwgc/vol1/home/czaka/tools/mitoscope/images/quay.io-czakarian-mitoscope-blast_2.16.0.img blastn \
     -query ${flankdir}/numt_${id}_nuc.fasta \
     -subject ${flankdir}/numt_${id}_mito_left.fasta \
     -out ${flankdir}/numt_${id}_out_left.txt \
     -word_size 4 -outfmt "6 qseqid sseqid length" -perc_identity 100

    /net/nwgc/vol1/home/czaka/tools/mitoscope/images/quay.io-czakarian-mitoscope-blast_2.16.0.img blastn \
     -query ${flankdir}/numt_${id}_nuc.fasta \
     -subject ${flankdir}/numt_${id}_mito_right.fasta \
     -out ${flankdir}/numt_${id}_out_right.txt \
     -word_size 4 -outfmt "6 qseqid sseqid length" -perc_identity 100

    if [ ! -s "${flankdir}/numt_${id}_out_left.txt" ]; then
        echo -e "numt_${id}_nuc\tnumt_${id}_mito_left\tNA" >> ${collapsed_file}
    else
        head -1 ${flankdir}/numt_${id}_out_left.txt >> ${collapsed_file}
    fi
    
    if [ ! -s "${flankdir}/numt_${id}_out_right.txt" ]; then
        echo -e "numt_${id}_nuc\tnumt_${id}_mito_right\tNA" >> ${collapsed_file}
    else
        head -1 ${flankdir}/numt_${id}_out_right.txt >> ${collapsed_file}
    fi
    
    rm ${flankdir}/numt_${id}_nuc.fasta ${flankdir}/numt_${id}_mito_left.fasta ${flankdir}/numt_${id}_mito_right.fasta

done


