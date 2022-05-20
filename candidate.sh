#!/bin/bash

input="probe.txt"

while IFS="," read a b c d e f; do
  fasta_file=$a
  gene_name=$b
  gene_chr=$c
  gene_start=$d
  gene_end=$e
  outdir=$f
  Rscript mismatch_tm_candidates.R ${fasta_file} ${gene_name} ${gene_chr} ${gene_start} ${gene_end} ${outdir}
done < "$input"
