"""
Assembly rules
Illumina paired end reads - Megahit
Nanopore reads - Flye
"""

rule flye:
    """Assemble longreads with Flye"""
    input:
        lambda wildcards: os.path.join(dir.nanopore, f"{wildcards.sample}_S{'.subsampled' if config.params.subsample == '--subsample' else ''}.fastq.gz"),
    threads:
        config.resources.bigjob.cpu
    resources:
        mem_mb=config.resources.bigjob.mem,
        time=config.resources.bigjob.time
    output:
        fasta = os.path.join(dir.flye, "{sample}-sr", "assembly.fasta"),
        gfa = os.path.join(dir.flye, "{sample}-sr", "assembly_graph.gfa"),
        path= os.path.join(dir.flye, "{sample}-sr", "assembly_info.txt")
    params:
        out= os.path.join(dir.flye, "{sample}-sr"),
        model = config.params.flye,
        g = config.params.genomeSize
    log:
        os.path.join(dir.log, "flye.{sample}.log")
    benchmark:
        os.path.join(dir.bench,"flye.{sample}.txt")
    conda:
        os.path.join(dir.env, "flye.yaml")
    shell:
        """
        flye \
            {params.model} \
            {input} \
            --threads {threads}  \
            --asm-coverage 50 \
            --genome-size {params.g} \
            --out-dir {params.out} \
            2> {log}
        """


rule medaka:
    """Polish longread assembly with medaka"""
    input:
        fasta = os.path.join(dir.flye, "{sample}-sr", "assembly.fasta"),
        fastq = lambda wildcards: os.path.join(dir.nanopore, f"{wildcards.sample}_S{'.subsampled' if config.params.subsample == '--subsample' else ''}.fastq.gz"),

    output:
        fasta = os.path.join(dir.flye,"{sample}-sr", "consensus.fasta")
    conda:
        os.path.join(dir.env, "medaka.yaml")
    params:
        model = config.params.medaka,
        dir= directory(os.path.join(dir.flye,"{sample}-sr"))
    threads:
        config.resources.bigjob.cpu
    resources:
        mem_mb=config.resources.bigjob.mem,
        time=config.resources.bigjob.time
    log:
        os.path.join(dir.log, "medaka.{sample}.log")
    benchmark:
        os.path.join(dir.bench, "medaka.{sample}.txt")
    shell:
        """
        medaka_consensus \
            -i {input.fastq} \
            -d {input.fasta} \
            -o {params.dir} \
            -m {params.model} \
            -t {threads} \
            2> {log}
        """

rule megahit:
    """Assemble short reads with MEGAHIT"""
    input:
        r1 = lambda wildcards: os.path.join(dir.prinseq, f"{wildcards.sample}_R1{'.subsampled' if config.params.subsample == '--subsample' else ''}.fastq.gz"),
        r2 = lambda wildcards: os.path.join(dir.prinseq, f"{wildcards.sample}_R2{'.subsampled' if config.params.subsample == '--subsample' else ''}.fastq.gz"),
        s =  lambda wildcards: os.path.join(dir.prinseq, f"{wildcards.sample}_RS{'.subsampled' if config.params.subsample == '--subsample' else ''}.fastq.gz"),
    output:
        os.path.join(dir.megahit, "{sample}-pr", "final.contigs.fa")
    params:
        os.path.join(dir.megahit, "{sample}-pr")
    log:
        os.path.join(dir.log, "megahit.{sample}.log")
    benchmark:
        os.path.join(dir.bench, "megahit.{sample}.txt")
    threads:
        config.resources.bigjob.cpu
    resources:
        mem_mb=config.resources.bigjob.mem,
        time=config.resources.bigjob.time
    conda:
        os.path.join(dir.env, "megahit.yaml")
    shell:
        """
        if [[ -d {params} ]]
        then
            rm -rf {params}
        fi
        megahit \
            -1 {input.r1} \
            -2 {input.r2} \
            -r {input.s} \
            -o {params} \
            -t {threads} \
            2> {log}
        """

rule fastg:
    """Save the MEGAHIT graph"""
    input:
        os.path.join(dir.megahit, "{sample}-pr", "final.contigs.fa")
    output:
        fastg=os.path.join(dir.megahit, "{sample}-pr", "final.fastg"),
        graph=os.path.join(dir.megahit, "{sample}-pr", "final.gfa")
    conda:
        os.path.join(dir.env, "megahit.yaml")
    log:
        os.path.join(dir.log, "fastg.{sample}.log")
    benchmark:
        os.path.join(dir.bench, "fastg.{sample}.txt")
    shell:
        """
        if [[ -s {input} ]]
        then
            kmer=$(head -1 {input} | sed 's/>//' | sed 's/_.*//')
            megahit_toolkit contig2fastg $kmer {input} > {output.fastg} 2> {log}
            Bandage reduce {output.fastg} {output.graph} 2>> {log}
        fi
        """
