
configfile: "config/config.yaml"

FNAMES = glob_wildcards("data/{fname}.fasta").fname

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

