
# Dependencies 

1. Nucleotide-Nucleotide BLAST 2.9.0+
2. R version 4.0 and above
3. automake/1.15 


# Probe Maker 

Probe Maker has built as executable program using Make and it is intended for design of probes for Plasmodium falciparum for long-read sequencing technologies. It is comprised of three main steps - initial probe findings to conserved regions, nucleotide blast, and final probe selection.  Based on the species would like to be designed, the following files (inside data directory) need to be changed accordingly.

1. pf3k.rds (species specific) (*Plasmodium falciparum* variant database based on [Naung *et al.*, 2022](https://github.com/myonaung/Naung-et-al-2021)).
2. BLAST Database (access for *Plasmodium falciparum* (3D7),   *Plasmodium vivax* (Pv01), and Human (Hg38))



# Usage

First of all, **probe.txt** file is required to be replaced by the informations of the gene that need to be used. The input information to the probe.txt  has to be in the exact order as shown in the example (i.e. ref/reference.fasta, gene ID, chromosome ID, start coordinate, end  coordinate, output directory). Comma (,) is required to seperate between each input information. The required reference gene in FastA format has be placed inside the **ref folder**.

After loading BLAST and R > 4.0 in the computation environment, Probe Maker can be executed as following:

```
cd path_to_probe_maker
make all
```

Each step of the software can be run separately given that the required input for each step has completed.

```
make help
```

```
Usage:
  make all                      #entire pipeline

Usage:
  make candidate                #for initial step

Usage:
  make blast                    #blastn but need outputs from candidate step

Usage:
  make final_probes             #final probe selection but need outputs from candidate and blast steps
```
