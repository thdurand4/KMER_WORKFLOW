import os
from os.path import exists

configfile: "config/config.yaml"

#Stockage des chemins des scripts et des accessions dans des variables à partir du fichier config
accessions = config['DATA']['FASTQ']
output_dir = config['DATA']['OUTPUT_DIR']
script_dir = config['DATA']['SCRIPTS']
merge_table_name = config['OPTIONAL']['MERGE_TABLE']
subset_table_name = config['OPTIONAL']['SUBSET_TABLE']
upset_table_name = config['OPTIONAL']['UPSET_TABLE']
upset_plot = config['OPTIONAL']['UPSET_PLOT']
fastq = config['DATA']['LIST_ACCESSION']


with open(fastq,"r") as f1:
    for lignes in f1:
        ligne = lignes.rstrip("\n")
        id = ligne.split("\t")
        if not exists(accessions+id[0]+".fastq.gz"):
            os.system("ln -s "+id[1]+" "+accessions+id[0]+".fastq.gz")

log_dir = f"{output_dir}LOGS/"

# Récupération du basename de nos accessions
RENAME_ACC, = glob_wildcards(f"{accessions}{{samples}}.fastq.gz", followlinks=True)

print(RENAME_ACC)

def get_threads(rule, default):
    """
    give threads or 'cpus-per-task from cluster_config rule : threads to SGE and cpus-per-task to SLURM
    """
    if rule in cluster_config and 'threads' in cluster_config[rule]:
        return int(cluster_config[rule]['threads'])
    elif '__default__' in cluster_config and 'threads' in cluster_config['__default__']:
        return int(cluster_config['__default__']['threads'])
    return default


rule finale:
    input:
        upset_final = expand(f"{output_dir}7_UPSET_PLOT/{upset_plot}", samples = RENAME_ACC)


rule sub_set20M :
    threads: get_threads("sub_set20M",5)
    input:
        acces_renamed = f"{accessions}{{samples}}.fastq.gz"
    output:
        accession_20M = f"{output_dir}1_ACCESSION_20M_READS/{{samples}}_20M.fastq"
    params:
        seqtk_options = config["TOOLS_PARAMS"]["SEQTK_SAMPLE"]
    log :
        error =  f'{log_dir}sub_set20M/sub_set20M_{{samples}}.e',
        output = f'{log_dir}sub_set20M/sub_set20M_{{samples}}.o'
    message:
            f"""
             Running {{rule}}
                Input:
                    - Fastq ALL : {{input.acces_renamed}}
                Output:
                    - Fastq 20M: {{output.accession_20M}}
                Others
                    - Threads : {{threads}}
                    - LOG error: {{log.error}}
                    - LOG output: {{log.output}}

            """
    envmodules:
        "seqtk"
    shell:
        f"seqtk sample {{input.acces_renamed}} {{params.seqtk_options}} > {{output.accession_20M}} 2>{{log.error}}"

rule kmer_count :
    threads: get_threads("kmer_count",4)
    input:
        acces_20M = rules.sub_set20M.output
    output:
        binary_tab = f"{output_dir}2_KMER_COUNT/BINARY_TABLE/{{samples}}/{{samples}}_20M.jf50"
    params:
        kat_options = config["TOOLS_PARAMS"]["KAT_HIST"],
        wrong_name= f"{output_dir}2_KMER_COUNT/BINARY_TABLE/{{samples}}/{{samples}}_20M.jf50-hash.jf50"
    log :
        error =  f'{log_dir}kmer_count/kmer_count_{{samples}}.e',
        output = f'{log_dir}kmer_count/kmer_count_{{samples}}.o'
    message:
            f"""
             Running {{rule}}
                Input:
                    - Accession 20M : {{input.acces_20M}}
                Output:
                    - Binary File : {{output.binary_tab}}
                Others
                    - Threads : {{threads}}
                    - LOG error: {{log.error}}
                    - LOG output: {{log.output}}

            """
    envmodules:
        "kat"
    shell:
        """
        kat hist -o {output.binary_tab} {params.kat_options} {input.acces_20M} 1>{log.output} 2>{log.error}
        mv {params.wrong_name} {output.binary_tab}
        """


rule binary_to_tbl :
    threads: get_threads("binary_to_tbl",4)
    input:
        binary_file = rules.kmer_count.output
    output:
        table_kmer = f"{output_dir}3_KMER_COVERAGE/TABLE/{{samples}}/{{samples}}_20M_coverage.tbl"
    params:
        jellyfish_dump = config["TOOLS_PARAMS"]["JELLYFISH_DUMP"]
    log :
        error = f'{log_dir}binary_to_tbl/binary_to_tbl_{{samples}}.e',
        output = f'{log_dir}binary_to_tbl/binary_to_tbl_{{samples}}.o'
    message:
            f"""
             Running {{rule}}
                Input : 
                    - Binary File : {{input.binary_file}}
                Output : 
                    - Tabulate Coverage File : {{output.table_kmer}}
                Others :
                    - Threads : {{threads}}
                    - LOG error : {{log.error}}
                    - LOG output : {{log.output}}
            
            """
    envmodules:
        "jellyfish/2.3.0"
    shell:
        f"jellyfish dump {{params.jellyfish_dump}} -o {{output.table_kmer}} {{input.binary_file}} 1>{{log.output}} 2>{{log.error}}"


rule sorted_table:
    threads: get_threads("sorted_table",4)
    input:
        tabulate_file=rules.binary_to_tbl.output
    output:
        table_sorted=f"{output_dir}4_KMER_SORTED/TABLE/{{samples}}/{{samples}}_20M_coverage_sorted.tbl"
    params:
        kmer_coverage=config["TOOLS_PARAMS"]["SORTED_TABLE"]
    log:
        error=f'{log_dir}sorted_table/sorted_table_{{samples}}.e',
        output=f'{log_dir}sorted_table/sorted_table_{{samples}}.o'
    message:
        f"""
             Running {{rule}}
                Input : 
                    - Tabulate Coverage File : {{input.tabulate_file}}
                Output : 
                    - Tabulate Sorted File : {{output.table_sorted}}
                Others :
                    - Threads : {{threads}}
                    - LOG error : {{log.error}}
                    - LOG output : {{log.output}}

            """
    shell:
        f"sort {{params.kmer_coverage}} {{input.tabulate_file}} 1> {{output.table_sorted}} 2>{{log.error}}"

rule add_columns_names:
    threads: get_threads("add_columns_names",1)
    input:
        sorted_table = rules.sorted_table.output
    output:
        table_column_name = f"{output_dir}4_KMER_SORTED/TABLE/NAMED/{{samples}}_named.tbl"
    params:
        dir_all_files = f"{output_dir}4_KMER_SORTED/TABLE/NAMED/"
    log:
        error = f'{log_dir}add_columns_names/add_columns_names_{{samples}}.e',
        output = f'{log_dir}add_columns_names/add_columns_names_{{samples}}.o'
    message:
        f"""
             Running {{rule}}
                Input : 
                    - Tabulate Sorted File : {{input.sorted_table}}
                Output : 
                    - Tabulate Columns Named File : {{output.table_column_name}}
                Others :
                    - Threads : {{threads}}
                    - LOG error : {{log.error}}
                    - LOG output : {{log.output}}

            """
    envmodules:
        "python/3.8.2"
    shell:
        f"python {script_dir}name_columns.py -in {{input.sorted_table}} -o {{output.table_column_name}} 1> {{log.output}} 2> {{log.error}}"

rule merge_table:
    threads: get_threads("merge_table",5)
    input:
        table_column_name = expand(rules.add_columns_names.output, samples = RENAME_ACC)
    output:
        merged_table = f"{output_dir}5_MERGED_TABLE/ALL/{merge_table_name}.tbl"
    params:
        dir_all_files = f"{output_dir}4_KMER_SORTED/TABLE/NAMED/"
    log:
        error=f'{log_dir}merge_table/merge_table.e',
        output=f'{log_dir}merge_table/merge_table.o'
    message:
        f"""
             Running {{rule}}
                Input : 
                    - Tabulate Columns Named Files : {{params.dir_all_files}}
                Output : 
                    - Tabulate Merged File : {{output.merged_table}}
                Others :
                    - Threads : {{threads}}
                    - LOG error : {{log.error}}
                    - LOG output : {{log.output}}

            """
    envmodules:
        "python/3.8.2"
    shell:
        f"python {script_dir}merge_table.py -in {{params.dir_all_files}} -o {{output.merged_table}} 1> {{log.output}} 2> {{log.error}}"

rule subset_kmer:
    threads: get_threads("subset_kmer",7)
    input:
        table_merged = rules.merge_table.output if config["OPTIONAL"]["SUBSET_ACCESSION"] == "True" else []
    output:
        subset_table = f"{output_dir}5_MERGED_TABLE/SUBSET/{subset_table_name}.tbl" if config["OPTIONAL"]["SUBSET_ACCESSION"] == "True" else []
    log:
        error=f'{log_dir}subset_kmer/subset_kmer.e',
        output=f'{log_dir}subset_kmer/subset_kmer.o'
    message:
        f"""
             Running {{rule}}
                Input : 
                    - Merged Table : {{input.table_merged}}
                Output : 
                    - Subset Merged Table : {{output.subset_table}}
                Others :
                    - Threads : {{threads}}
                    - LOG error : {{log.error}}
                    - LOG output : {{log.output}}

            """
    envmodules:
        "python/3.8.2"
    shell:
        f"python {script_dir}subset_kmer.py -in {{input.table_merged}} -o {{output.subset_table}} -a {{config[DATA][LIST_SUBSET]}} -arg {{config[OPTIONAL][SUBSET_SCRIPT]}} 1> {{log.output}} 2> {{log.error}}"

rule parse_sub_set_kmer:
    threads: get_threads("parse_sub_set_kmer",7)
    input:
        table_merged = rules.subset_kmer.output if config["OPTIONAL"]["SUBSET_ACCESSION"] == "True" else [rules.merge_table.output]
    output:
        upset_table = f"{output_dir}6_TABLE_FOR_UPSETPLOT/PARSED/{upset_table_name}.tbl"
    log:
        error=f'{log_dir}parse_sub_set_kmer/parse_sub_set_kmer.e',
        output=f'{log_dir}parse_sub_set_kmer/parse_sub_set_kmer.o'
    message:
        f"""
             Running {{rule}}
                Input : 
                    - Merged Table : {{input.table_merged}}
                Output : 
                    - Subset Merged Table : {{output.upset_table}}
                Others :
                    - Threads : {{threads}}
                    - LOG error : {{log.error}}
                    - LOG output : {{log.output}}

            """
    envmodules:
        "python/3.8.2"
    shell:
        f"python {script_dir}count_occurence_intersections.py --database {{input.table_merged}} --output {{output.upset_table}} 1> {{log.output}} 2> {{log.error}}"

rule upset_plot:
    threads: get_threads("upset_plot",1)
    input:
        upset_table = rules.parse_sub_set_kmer.output
    output:
        upset_plot = f"{output_dir}7_UPSET_PLOT/{upset_plot}"
    params:
        list_color = config["DATA"]["LIST_COULEURS"]
    log:
        error=f'{log_dir}upset_plot/upset_plot.e',
        output=f'{log_dir}upset_plot/upset_plot.o'
    message:
        f"""
                 Running {{rule}}
                    Input : 
                        - Upset Table : {{input.upset_table}}
                    Output : 
                        - Upset Plot : {{output.upset_plot}}
                    Others :
                        - Threads : {{threads}}
                        - LOG error : {{log.error}}
                        - LOG output : {{log.output}}

                """
    envmodules:
        "perllib/5.16.3"
    shell:
        f"perl {script_dir}GraphKmer_v2.pl -in {{input.upset_table}} -list {{params.list_color}} -outprefix {{output.upset_plot}} 1> {{log.output}} 2> {{log.error}}"


