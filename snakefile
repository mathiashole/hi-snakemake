
configfile: "config/config.yaml" # extract main information similar to arguments

FNAMES = glob_wildcards("data/{fname}.fasta").fname # search all file that contain this structure "data/{X}.fasta"

# main rule, call all rules
rule all:
    input:
        expand("results/qc/{fname}.validated.txt", fname=FNAMES),
        expand("results/tables/{fname}_gc.tsv", fname=FNAMES),
        expand("results/tables/{fname}_nuc.tsv", fname=FNAMES),
        "results/tables/combined_table.tsv",
        "results/plots/summary_plot.pdf",
        "results/report.html"

rule validate_fasta:
    input:
        fasta="data/{fname}.fasta"
    output:
        txt="results/qc/{fname}.validated.txt"
    shell:
        """
        seqkit stats {input.fasta} > {output.txt}
        """

rule gc_content:
    input:
        fasta="data/{fname}.fasta"
    output:
        tsv="results/tables/{fname}_gc.tsv"
    shell:
        """
        seqkit fx2tab -g -n -i {input.fasta} > {output.tsv}
        """

rule infoseq_stats:
    input:
        "data/{fname}.fasta"
    output:
        "results/tables/{fname}_stats.tsv"
    shell:
        """
        infoseq {input} -only -name -length -pgc | awk 'BEGIN {{OFS="\\t"; print "seq_id","length","gc"}} NR>1 {{print $1,$2,$3}}' > {output}
        """
