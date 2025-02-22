"""
Rules for quality control and quality assurance - Illumina paired end reads 
"""

rule write_samples_tsv:
    output:
        tsv = temp(os.path.join(dir.temp,"samples.reads.tsv"))
    params:
        sample_dict = samples.reads
    localrule: True
    run:
        from metasnek import fastq_finder
        fastq_finder.write_samples_tsv(params.sample_dict, output.tsv)


rule trimnami:
    input:
        os.path.join(dir.temp,"samples.reads.tsv")
    output:
        targets.qc
    conda:
        os.path.join(dir.env, "trimnami.yaml")
    threads:
        config.resources.bigjob.cpu
    resources:
        mem_mb = config.resources.bigjob.mem,
        time = config.resources.bigjob.time
    params:
        dir = dir.out,
        configfile = config.args.configfile,
        trimmer = lambda wildcards: "prinseq" if config.args.sequencing == "paired" else "filtlong",
        host = lambda wildcards: "--ref " + config.args.host if config.args.host else "",
        profile = lambda wildcards: "--profile " + config.args.profile if config.args.profile else "",
        fastp = lambda wildcards: config.args.adaptors if config.args.adaptors else "",
    log:
        os.path.join(dir.log, "trimnami.log")
    benchmark:
        os.path.join(dir.bench,"trimnami_paired.txt")
    shell:
        """
        trimnami run \
            --configfile {params.configfile} \
            --reads {input} \
            --output {params.dir} \
            --fastqc \
            --subsample \
            {params.trimmer} \
            {params.host} \
            {params.fastp} \
            {params.profile} \
            --log {log}
        """


rule build_trimnami:
    output:
        touch(os.path.join(dir.out, "trimnami.prebuild"))
    conda:
        os.path.join(dir.env, "trimnami.yaml")
    localrule:
        True
    shell:
        """
        trimnami run \
            --configfile {params.configfile} \
            --reads {input} \
            --output {params.dir} \
            --fastqc \
            --subsample \
            {params.trimmer} \
            {params.host} \
            {params.fastp} \
            {params.profile} \
            --log {log} \
            --conda-create-envs-only
        """