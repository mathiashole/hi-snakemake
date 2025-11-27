
configfile: "config/config.yaml" # extract main information similar to arguments

FNAMES = glob_wildcards("data/{fname}.fasta").fname # search all file that contain this structure "data/{X}.fasta"

ANALYSIS = config["analysis"]

# main rule; call all rules
rule all:
    input:
        expand("results/tables/{fname}_stats.tsv", fname=FNAMES),
        "results/tables/combined_table.tsv",
        "results/plots/summary_plot.pdf",
        "results/report.html"

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
rule infoseq_stats:
    input:
        "data/{fname}.fasta"
    output:
        "results/tables/{fname}_stats.tsv"
    shell:
        """
        infoseq {input} -only -name -length -pgc | awk 'BEGIN {{OFS="\\t"; print "seq_id","length","gc"}} NR>1 {{print $1,$2,$3}}' > {output}
        """

# combine all stat table per multifasta
rule combine_tables:
    input:
        expand("results/tables/{fname}_stats.tsv", fname=FNAMES)
    output:
        "results/tables/combined_table.tsv"
    shell:
        """
        (echo -e "file\tseq_id\tlength\tgc";
        for f in {input}; do
            fname=$(basename "$f" _stats.tsv);
            tail -n +2 "$f" | awk -v name=$fname '{{print name"\t"$0}}';
        done) > {output}
        """
# create gc and length plot in pdf format
rule plot_stats:
    input:
        "results/tables/combined_table.tsv"
    output:
        "results/plots/summary_plot.pdf"
    script:
        "scripts/plot_stats.R"
