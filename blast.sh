#!/bin/bash

input="probe.txt"

while IFS="," read a b c d e f; do
  fasta_file=$a
  gene_name=$b
  gene_chr=$c
  gene_start=$d
  gene_end=$e
  outdir=$f
  blastn -query ${outdir}/${gene_name}_probes_candidates.fasta -task 'blastn' -db "data/Blast_DB/PfBaits" -out /dev/stdout -outfmt "6 qseqid length" -perc_identity 95 -evalue 1000 -culling_limit 10 -dust 'no' | awk '{if ($2>=100) tot[$1]++;} END {for (query in tot) {if (tot[query]==1) print query;}}' > ${outdir}/${gene_name}_blast_candidates.txt
done < "$input"


