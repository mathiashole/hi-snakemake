# Snakefile for processing FASTA files: validation, stats calculation, frequency analysis, and report generation.
# Author: Mathias Mangino
# Date: 2025

# Load configuration file
configfile: "config/config.yaml" # extract main information similar to arguments

FNAMES = glob_wildcards("data/{fname}.fasta").fname # search all file that contain this structure "data/{X}.fasta"

FASTAS = expand("data/{fname}.fasta", fname=FNAMES) # list of all file in data with fasta tag

ANALYSIS = config["analysis"] #extract analysis of config

# main rule; call all rules
# define all output files
rule all:
    input:
        expand("results/tables/{fname}_stats.tsv", fname=FNAMES),
        "results/tables/combined_table.tsv",
        "results/plots/summary_plot.pdf",
        expand("results/frequency/{atype}_combined.tsv", atype=ANALYSIS),
        expand("results/plots/{atype}_combined.pdf", atype=ANALYSIS),
        "results/report.html"

# seqkit validation rule
rule validate_fasta: # short validation and make main stat
    input:
        fasta="data/{fname}.fasta"
    output:
        txt="results/qc/{fname}.validated.txt"
    shell:
        """
        seqkit stats {input.fasta} > {output.txt}
        """

# this rule calculate gc and length of sequence
# uses infoseq from emboss package
rule infoseq_stats:
    input:
        "data/{fname}.fasta"
    output:
        "results/tables/{fname}_stats.tsv"
    shell:
        """
        infoseq {input} -only -name -length -pgc | awk 'BEGIN {{OFS="\\t"; print "seq_id","length","gc"}} NR>1 {{print $1,$2,$3}}' > {output}
        """


# combine all individual tables into one table with an additional column indicating the source file
rule combine_tables:
    input:
        expand("results/tables/{fname}_stats.tsv", fname=FNAMES)
    output:
        "results/tables/combined_table.tsv"
    shell:
        """
        (echo -e "file\tseq_id\tlength\tgc"; # create Header of combined file
        for f in {input}; do # iterate over input files
            fname=$(basename "$f" _stats.tsv); # extract filename without path and suffix
            tail -n +2 "$f" | awk -v name=$fname '{{print name"\t"$0}}'; # add filename as first column
        done) > {output} # redirect output to combined file
        """

# Frequency analysis rule
# for each analysis type specified in config file
rule frequency_analysis:
    input:
        FASTAS
    output:
        "results/frequency/{atype}_combined.tsv"
    shell:
        """
        Rscript scripts/allFrequency.R --{wildcards.atype} {input} --output results/frequency/{wildcards.atype}

        mv results/frequency/{wildcards.atype}_{wildcards.atype}_frequencies.tsv {output}
        """

# create gc and length plot in pdf format
#  generate summary plot
rule plot_stats:
    input:
        "results/tables/combined_table.tsv"
    output:
        "results/plots/summary_plot.pdf"
    script:
        "scripts/plot_stats.R"

# create frequency plot in pdf format
# generate frequency plot for each analysis type
rule plot_frequency:
    input:
        "results/frequency/{atype}_combined.tsv"
    output:
        "results/plots/{atype}_combined.pdf"
    script:
        "scripts/plot_frequency.R"
