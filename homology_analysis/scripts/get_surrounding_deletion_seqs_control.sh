#!/bin/bash

set -euo pipefail

module load modules modules-init modules-gs
module load samtools/1.21

GENOME_LEN=16569
flank=20

MT_REF="/net/nwgc/vol1/home/czaka/tools/mitoscope/resources/MT.fasta"
infile="/net/nwgc/vol1/home/czaka/analysis/mitoscope/smaht/analysis/homology_analysis/deletion_coordinates_nodups.tsv"
flankdir="/net/nwgc/vol1/home/czaka/analysis/mitoscope/smaht/analysis/homology_analysis/del_flanks_control_all"
collapsed_file="/net/nwgc/vol1/home/czaka/analysis/mitoscope/smaht/analysis/homology_analysis/del_flanks_control_all.tsv"

mkdir -p $flankdir

export SINGULARITY_BINDPATH="${flankdir}"

echo "header" > ${collapsed_file}

tail +2 ${infile} | while IFS= read -r line; do
    
    id=$(echo $line | awk '{print $1"_"$2}')
    del_start=$(echo $line | awk '{print $1}')
    del_end=$(echo $line | awk '{print $2}')

    for i in {1..5};
    do
        while true; do 
            offset=$(( RANDOM % ($GENOME_LEN-1) + 1 ))

            new_start=$(( ($del_start + $offset - 1) % $GENOME_LEN + 1 ))
            new_end=$(( ($del_end + $offset - 1) % $GENOME_LEN + 1 ))

            start_left=$new_start
            start_right=$(( $new_start + $flank ))

            end_left=$new_end
            end_right=$(( $new_end + $flank ))

            if (( $start_right <= $GENOME_LEN && $end_right <= $GENOME_LEN)); then
                break
            fi
        done
    

        del_start_span=$(samtools faidx ${MT_REF} MT:${start_left}-${start_right})
        del_end_span=$(samtools faidx ${MT_REF} MT:${end_left}-${end_right})
    
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

done



