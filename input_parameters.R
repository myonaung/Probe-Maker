
# ======================= INPUT PARAMETERS AND DATA ================

# bait parameters
bait_length <- 120
temp_lower <- 63 # default = 68
temp_upper <- 120
max_mismatches <- 6 #default = 6
min_sep <- 250 #default = 500
ideal_sep <- c(300, 1000) #default 700,1000

# enthalphy and entropy nearest neighbour values for DNA
# source: https://www.sigmaaldrich.com/technical-documents/articles/biology/oligos-melting-temp.html
H <- S <- list()
H[["AA"]] <- H[["TT"]] <- -9.1
H[["AT"]] <- -8.6
H[["TA"]] <- -6.0
H[["CA"]] <- H[["TG"]] <- -5.8
H[["GT"]] <- H[["AC"]] <- -6.5
H[["CT"]] <- H[["AG"]] <- -7.8
H[["GA"]] <- H[["TC"]] <- -5.6
H[["CG"]] <- -11.9
H[["GC"]] <- -11.1
H[["GG"]] <- H[["CC"]] <- -11.0

S[["AA"]] <- S[["TT"]] <- -0.0240
S[["AT"]] <- -0.0239
S[["TA"]] <- -0.0169
S[["CA"]] <- S[["TG"]] <- -0.0129
S[["GT"]] <- S[["AC"]] <- -0.0173
S[["CT"]] <- S[["AG"]] <- -0.0208
S[["GA"]] <- S[["TC"]] <- -0.0135
S[["CG"]] <- -0.0278
S[["GC"]] <- -0.0267
S[["GG"]] <- S[["CC"]] <- -0.0266

# constants
R = 0.00199 # gas constant, kCal/(K mol)
A = -0.0108 # helix initiation kCal/(K mol)ca
C = 0.000001 # oligonucleotide concentration (M) #default = 0.0000005
Na = 0.1 # Na+ ion concentration (M)

# ======================= HELPER FUNCTIONS ================

# generate FASTA file of candidate probes
generate_fasta <- function(candidates, gene_name, file_suffix, outdir) {
  for (i in 1:nrow(candidates)) {
    cat(paste0(">", gene_name, ":", candidates[i,]$start, "-", candidates[i,]$end, "\n"),
        file=paste0(outdir, "/", gene_name, file_suffix), append=TRUE)
    cat(paste0(substr(gene_seq, candidates[i,]$start, candidates[i,]$end), "\n"),
        file=paste0(outdir, "/", gene_name, file_suffix), append=TRUE)
  }
}

