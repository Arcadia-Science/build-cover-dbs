KSIZES = [21, 31, 51]
LINEAGES=['bacteria', 'viral', 'archaea', 'fungi', 'protozoa']

rule all:
    input:
        expand("outputs/sourmash_database_covers/genbank-2022.03-k{ksize}-scaled100k-cover.zip", ksize = KSIZES)

rule download_db_cover_script:
    output: "scripts/make-db-cover.py"
    shell:'''
    curl -JLo {output} https://raw.githubusercontent.com/ctb/2022-database-covers/165c76675d93a8054b8d0140d9b70fe6cff7fd2f/make-db-cover.py
    '''

#################################################################
## Build covers for existing databases
#################################################################

rule download_sourmash_databases_genbank:
    input: "inputs/sourmash_databases/sourmash-database-info.csv"
    output: "inputs/sourmash_databases/genbank-2022.03-{lineage}-k{ksize}.zip"
    run:
        sourmash_database_info = pd.read_csv(str(input[0]))
        ksize = int(wildcards.ksize)
        lineage_df = sourmash_database_info.loc[(sourmash_database_info['lineage'] == wildcards.lineage) & (sourmash_database_info['ksize'] == ksize)]
        if lineage_df is None:
            raise TypeError("'None' value provided for lineage_df. Are you sure the sourmash database info csv was not empty?")

        osf_hash = lineage_df['osf_hash'].values[0] 
        shell("curl -JLo {output} https://osf.io/{osf_hash}/download")

rule build_cover:
    input: 
        script = "scripts/make-db-cover.py",
        db = "inputs/sourmash_databases/genbank-2022.03-{lineage}-k{ksize}.zip"
    output: "outputs/sourmash_database_covers/genbank-2022.03-{lineage}-k{ksize}-scaled1k-cover.zip"
    conda: "envs/sourmash.yml"
    shell:'''
    ./{input.script} {input.db} -o {output}
    '''

rule downsample_cover:
    input: "outputs/sourmash_database_covers/genbank-2022.03-{lineage}-k{ksize}-scaled1k-cover.zip"
    output: "outputs/sourmash_database_covers/genbank-2022.03-{lineage}-k{ksize}-scaled100k-cover.zip"
    conda: "envs/sourmash.yml"
    shell:'''
    sourmash sig downsample --scaled 100000 -o {output} {input} 
    '''

rule combine_covers_into_single_db:
    input: expand("outputs/sourmash_database_covers/genbank-2022.03-{lineage}-k{{ksize}}-scaled100k-cover.zip", lineage = LINEAGES)
    output: "outputs/sourmash_database_covers/genbank-2022.03-k{ksize}-scaled100k-cover.zip"
    conda: "envs/sourmash.yml"
    shell:'''
    sourmash sig cat {input} -o {output}
    '''
