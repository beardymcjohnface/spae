"""
Building bedfiles to visusalize the genome coverage per base
"""

rule genome_coverage_paired:
    input:
        ref = os.path.join(dir.genome, "{sample}-pr", "{sample}.fasta"),
        reads = os.path.join(dir.temp,"{sample}.paired.tsv")
    output:
        bam= os.path.join(dir.genome,"{sample}-pr", "temp", "{sample}.bam"),
        bai= os.path.join(dir.genome,"{sample}-pr", "temp", "{sample}.bam.bai"),
        tsv= os.path.join(dir.genome,"{sample}-pr", "temp", "{sample}.cov")
    params:
        out = os.path.join(dir.genome, "{sample}-pr"),
    conda:
        os.path.join(dir.env, "koverage.yaml")
    threads:
        config.resources.smalljob.cpu
    resources:
        mem_mb=config.resources.smalljob.mem,
        time=config.resources.smalljob.time
    log:
        os.path.join(dir.log, "contig_coverage_spades.{sample}.log")
    benchmark:
        os.path.join(dir.bench, "contig_coverage_spades.{sample}.txt")
    shell:
        """
        koverage run coverm \
            --reads {input.reads} \
            --ref {input.ref} \
            --output {params.out} \
            --threads {threads} \
            --log {log}
        """

rule genomecov_paired:
    input:
        bam = os.path.join(dir.genome, "{sample}-pr", "temp", "{sample}.bam"),
        bai = os.path.join(dir.genome, "{sample}-pr", "temp", "{sample}.bam.bai"),
    output:
        tsv=  os.path.join(dir.genome, "{sample}-pr", "temp", "megahit_{sample}.gencov.tsv")
    threads:
        config.resources.smalljob.cpu
    resources:
        mem_mb=config.resources.smalljob.mem,
        time=config.resources.smalljob.time
    log:
        os.path.join(dir.log, "genomecov_paired.{sample}.log")
    benchmark:
        os.path.join(dir.bench,"genomecov_paired.{sample}.txt")
    conda:
        os.path.join(dir.env, "bedtools.yaml")
    shell:
        """
        if [[ -s {input.bam} ]]
        then
            bedtools genomecov \
                -ibam {input.bam} \
                -d \
                > {output.tsv} \
                2> {log}
        fi
        """

rule genome_coverage_nanopore:
    input:
        ref = os.path.join(dir.genome, "{sample}-sr", "{sample}.fasta"),
        read = os.path.join(dir.temp, "{sample}.single.tsv")
    output:
        bam = os.path.join(dir.genome, "{sample}-sr", "temp", "{sample}.bam"),
        bai = os.path.join(dir.genome, "{sample}-sr", "temp", "{sample}.bam.bai"),
        tsv = os.path.join(dir.genome,"{sample}-sr", "temp", "{sample}.cov")
    params:
        out = os.path.join(dir.genome, "{sample}-sr")
    conda:
        os.path.join(dir.env, "koverage.yaml")
    threads:
        config.resources.smalljob.cpu
    resources:
        mem_mb=config.resources.smalljob.mem,
        time=config.resources.smalljob.time
    log:
        os.path.join(dir.log, "contig_coverage_flye_nano.{sample}.log")
    benchmark:
        os.path.join(dir.bench, "contig_coverage_flye_nano.{sample}.txt")
    shell:
        """
        koverage run coverm \
            --minimap map-ont \
            --reads {input.read} \
            --ref {input.ref} \
            --output {params.out} \
            --threads {threads} \
            --log {log}
        """

rule genomecov_nanopore:
    input:
        bam = os.path.join(dir.genome, "{sample}-sr", "temp", "{sample}.bam"),
        bai = os.path.join(dir.genome, "{sample}-sr", "temp", "{sample}.bam.bai"),
    output:
        tsv=  os.path.join(dir.genome, "{sample}-sr", "temp", "flye_{sample}.gencov.tsv")
    threads:
        config.resources.smalljob.cpu
    resources:
        mem_mb=config.resources.smalljob.mem,
        time=config.resources.smalljob.time
    log:
        os.path.join(dir.log, "genomecov_nanopore.{sample}.log")
    benchmark:
        os.path.join(dir.bench,"genomecov_nanopore.{sample}.txt")
    conda:
        os.path.join(dir.env, "bedtools.yaml")
    shell:
        """
        if [[ -s {input.bam} ]]
        then
            bedtools genomecov \
                -ibam {input.bam} \
                -d \
                > {output.tsv} \
                2> {log}
        fi
        """