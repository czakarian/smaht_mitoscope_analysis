#!/bin/bash

module load modules modules-init modules-gs
module load samtools/1.21

flank=3
MT_REF="/net/nwgc/vol1/home/czaka/tools/mitoscope/resources/MT.fasta"
NUC_REF="/net/nwgc/vol1/home/czaka/ref/GRCh38_no_alt_analysis_set.fasta"

infile="/net/nwgc/vol1/home/czaka/analysis/mitoscope/smaht/analysis/homology_analysis/smaht_benchmarking_tissue_unique_numts.tsv"
outfile="/net/nwgc/vol1/home/czaka/analysis/mitoscope/smaht/analysis/homology_analysis/smaht_benchmarking_tissue_unique_numts.trinuc.tsv"

echo -e "id\tnuc_left_seq\tnuc_right_seq\tmito_outer_left_seq\tmito_outer_right_seq\tmito_inner_left_seq\tmito_inner_right_seq" > $outfile

tail +2 ${infile} | while IFS= read -r line; do
    echo $line
    nuc_chrom=$(echo $line | awk '{print $3}')
    nuc_pos=$(echo $line | awk '{print $4}')
    mito_start=$(echo $line | awk '{print $6}')
    mito_end=$(echo $line | awk '{print $7}')
    id=$(echo $line | awk '{print $2}')

    nuc_left=$(samtools faidx ${NUC_REF} ${nuc_chrom}:$((${nuc_pos} - ${flank} + 1))-$((${nuc_pos})))
    nuc_right=$(samtools faidx ${NUC_REF} ${nuc_chrom}:$((${nuc_pos} + 1))-$((${nuc_pos} + ${flank})))
    mito_outer_left=$(samtools faidx ${MT_REF} MT:$((${mito_start} - ${flank}))-$((${mito_start} - 1)))
    mito_inner_left=$(samtools faidx ${MT_REF} MT:$((${mito_start}))-$((${mito_start} + ${flank} - 1)))
    mito_outer_right=$(samtools faidx ${MT_REF} MT:$((${mito_end} + 1))-$((${mito_end} + ${flank})))
    mito_inner_right=$(samtools faidx ${MT_REF} MT:$((${mito_end} - ${flank} + 1))-${mito_end})

    echo "nuc_left:", $nuc_left
    echo "nuc_right:", $nuc_right
    echo "mito_outer_left:", $mito_outer_left
    echo "mito_inner_left:", $mito_inner_left
    echo "mito_inner_right:", $mito_inner_right
    echo "mito_outer_right:", $mito_outer_right

    nuc_left_seq=$(echo $nuc_left | cut -d " " -f 2)
    nuc_right_seq=$(echo $nuc_right | cut -d " " -f 2)
    mito_outer_left_seq=$(echo $mito_outer_left | cut -d " " -f 2)
    mito_outer_right_seq=$(echo $mito_outer_right | cut -d " " -f 2)
    mito_inner_left_seq=$(echo $mito_inner_left | cut -d " " -f 2)
    mito_inner_right_seq=$(echo $mito_inner_right | cut -d " " -f 2)

    echo -e "${id}\t${nuc_left_seq}\t${nuc_right_seq}\t${mito_outer_left_seq}\t${mito_outer_right_seq}\t${mito_inner_left_seq}\t${mito_inner_right_seq}" >> $outfile


done


