# ======================= DEPENDENCIES ================
source("input_parameters.R")
library(stringr)
library(tidyr)
library(dplyr)
library(readr)

args = commandArgs(trailingOnly=TRUE)
fasta_file = args[1]
#fasta_file = "Ref_Gene/PF3D7_0312500.fasta"
gene_name = args[2]
#gene_name = "PF3D7_0312500"
gene_chr = args[3]
#gene_chr = "Pf3D7_03_v3"
gene_start = as.numeric(args[4])
#gene_start = as.numeric(528316)
gene_end = as.numeric(args[5])
#gene_end = as.numeric(531025)
outdir=args[6]
#outdir="/Users/naung.m/Documents/Bait_Finder_Pipeline/Bait_Finder/Probe_Sequences"
  
gene_seq <- read_lines(fasta_file, skip=1)  %>% toupper() %>%  paste(collapse='')
gene_len <- str_length(gene_seq)

# ===================== Pf3k DATASET - GLOBAL VARIATION ===============

# high quality SNP loci from in-house reanalysis of MalariaGEN Pf3k dataset
# we consider only SNPs passing GATK VQSR + relatively stringent hard filtration
# relax hard filtration parameters to account for a larger panel of possible variation

pf3k <- read_rds("data/pf3k.rds") %>%
  subset(qd>20 & sor<1 & mq>50 & (mqrank>-2 | is.nan(mqrank)) & 
           ((readpos>-4 & readpos<4) | is.nan(readpos))) %>%
  dplyr::select(chr, pos) %>% subset(chr==gene_chr & pos>=gene_start & pos<=gene_end)

# ======================= STAGE 1: MELTING TEMPERATURE ================

# melting temperature function
# source: https://www.sigmaaldrich.com/technical-documents/articles/biology/oligos-melting-temp.html

delta_h <- delta_s <- vector(mode="numeric", length=gene_len-1)

for (i in 1:(gene_len-1)) {
  delta_h[i] <- H[[ substr(gene_seq, i, i+1) ]]
  delta_s[i] <- S[[ substr(gene_seq, i, i+1) ]]
}

calculate_tm <- function(delta_h, delta_s, start, end) {
  sum_h <- sum(delta_h[start:(end-1)])
  sum_s <- sum(delta_s[start:(end-1)])
  Tm = sum_h / (A + sum_s + R * log(C/4)) - 273.15 + 16.6 * log(Na)
  return(Tm)
}

candidates <- data.frame(start=1:(gene_len-bait_length+1), end=bait_length:gene_len, Tm=0, num_snps=0)

for (i in 1:nrow(candidates)) {
  candidates[i,]$Tm <- calculate_tm(delta_h, delta_s, candidates[i,]$start, candidates[i,]$end)
}

candidates <- candidates %>% subset(Tm>=temp_lower & Tm<=temp_upper)

# ======================= STAGE 2: MISMATCH THRESHOLD ================

num_snps <- function(pf3k, chr, start, end) {
  pf3k %>% subset(chr==chr & pos>=start & pos<=end) %>% nrow %>% return()
}

for (i in 1:nrow(candidates)) {
  candidates[i,]$num_snps <- num_snps(pf3k, gene_chr, gene_start+candidates[i,]$start-1, 
                                      gene_start+candidates[i,]$end-1)
}

candidates <- candidates %>% subset(num_snps<=8)
rownames(candidates) <- paste0(gene_name, ":", candidates$start, "-", candidates$end)
write_rds(candidates, paste0(outdir, "/", gene_name, "_candidates.rds"))

# ======================= STAGE 3: GENERATE CANDIDATE PROBES FOR BLAST ================

generate_fasta(candidates, gene_name, "_probes_candidates.fasta", outdir)
