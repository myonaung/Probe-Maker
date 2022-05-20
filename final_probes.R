# ======================= DEPENDENCIES ================
library(stringr)
library(tidyr)
library(dplyr)
library(readr)
args = commandArgs(trailingOnly=TRUE)

fasta_file = args[1]
gene_name = args[2]
gene_chr = args[3]
gene_start = as.numeric(args[4])
gene_end = as.numeric(args[5])
outdir=args[6]

source("input_parameters.R")

gene_seq <- read_lines(fasta_file, skip=1) %>% toupper() %>%  paste(collapse='')
gene_len <- str_length(gene_seq)

# ======================= STAGE 4: PROBE SPACING ================

candidates <- read_rds(paste0(outdir, "/", gene_name, "_candidates.rds"))

unique_blast <- read_lines(paste0(outdir, "/", gene_name, "_blast_candidates.txt"))

candidates <- candidates[unique_blast,] %>% arrange(start)
candidates <- na.omit(candidates)
rownames(candidates) <- paste0(gene_name, ":", candidates$start, "-", candidates$end)

update_probe <- function(pos, candidates) {
  return(paste0(gene_name, ":", candidates[pos,]$start, "-", candidates[pos,]$end))
}

num_probes <- 1
probe_ids <- list()

# PROBE 1: select the probe with the min #mismatches from start 1-20;
# if no probes starting between 1-20bp, select probe closest to start
pos <- ifelse(candidates[1,]$start>20, 1, which.min((candidates %>% subset(start<=20))$num_snps))
probe_ids[[1]] <- update_probe(pos, candidates)
curr_end <- candidates[pos,]$end

# PROBE n, n>1
while ( (curr_end + ideal_sep[2]) < (gene_end-gene_start) ) {
  # 1) search for a probe within ideal range with minimal variation
  next_probe <- candidates %>% subset(start>curr_end+ideal_sep[1] & start<curr_end+ideal_sep[2])
  if (nrow(next_probe)>0) {
    pos <- which.min(next_probe$num_snps)
    # 2) search for a probe within min_sep to ideal_sep[1] (lower bound for probe separation)
    # with minimal variation
  } else {
    next_probe <- candidates %>% subset(start>curr_end+min_sep & start<curr_end+ideal_sep[1])
    if (nrow(next_probe)>0) {
      pos <- which.min(next_probe$num_snps)
      # 3) otherwise, simply pick closest probe
    } else {
      next_probe <- candidates %>% subset(start>curr_end+ideal_sep[2])
      pos <- 1
    }
  }  
  num_probes <- num_probes+1
  probe_ids[[num_probes]] <- update_probe(pos, next_probe)
  curr_end <- next_probe[pos,]$end
}

# generate FASTA file of candidate probes
generate_fasta(candidates[unlist(probe_ids),], gene_name, "_final_probes.fasta", outdir)

