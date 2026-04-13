#!/bin/bash

module load modules modules-init modules-gs
module load samtools/1.21

flank=20
MT_REF="/net/nwgc/vol1/home/czaka/tools/mitoscope/resources/MT.fasta"

infile="/net/nwgc/vol1/home/czaka/analysis/mitoscope/smaht/analysis/homology_analysis/deletion_coordinates_nodups.tsv"
flankdir="/net/nwgc/vol1/home/czaka/analysis/mitoscope/smaht/analysis/homology_analysis/del_flanks_all"
collapsed_file="/net/nwgc/vol1/home/czaka/analysis/mitoscope/smaht/analysis/homology_analysis/del_flank_all.tsv"


mkdir -p $flankdir

export SINGULARITY_BINDPATH="${flankdir}"

echo "header" > ${collapsed_file}

tail +2 ${infile} | while IFS= read -r line; do
    del_start=$(echo $line | awk '{print $1}')
    del_end=$(echo $line | awk '{print $2}')
    id=$(echo $line | awk '{print $1"_"$2}')
 
    del_start_span=$(samtools faidx ${MT_REF} MT:$((${del_start}))-$((${del_start} + ${flank})))
    del_end_span=$(samtools faidx ${MT_REF} MT:$((${del_end}))-$((${del_end} + ${flank})))

    del_start_seq=$(echo $del_start_span | cut -d " " -f 2)
    del_end_seq=$(echo $del_end_span | cut -d " " -f 2)

    echo -e ">${id}_left\n${del_start_seq}" > ${flankdir}/${id}_left.fasta
    echo -e ">${id}_right\n${del_end_seq}" > ${flankdir}/${id}_right.fasta

    /net/nwgc/vol1/home/czaka/tools/mitoscope/images/quay.io-czakarian-mitoscope-blast_2.16.0.img blastn \
     -query ${flankdir}/${id}_left.fasta \
     -subject ${flankdir}/${id}_right.fasta \
     -out ${flankdir}/${id}_out.txt \
     -word_size 4 -outfmt "6 qseqid sseqid length" -perc_identity 100

    if [ ! -s "${flankdir}/${id}_out.txt" ]; then
        echo -e "${id}_left\t${id}_right\tNA" >> ${collapsed_file}
    else
        head -1 ${flankdir}/${id}_out.txt >> ${collapsed_file}
    fi

    rm ${flankdir}/${id}_left.fasta ${flankdir}/${id}_right.fasta 

done



