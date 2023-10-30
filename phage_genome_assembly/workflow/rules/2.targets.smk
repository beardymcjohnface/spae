import attrmap as ap
import attrmap.utils as au


targets = ap.AttrMap()

targets.db = []

targets.db.append(os.path.join(dir.db, config.db.pfam_file))
targets.db.append(os.path.join(dir.db, 'pharokka_db', 'phrogs_db.index'))
targets.db.append(os.path.join(dir.db, 'checkv-db-v1.5', 'README.txt'))
targets.db.append(os.path.join(dir.db, 'phynteny_models', 'grid_search_model.m_400.b_256.lr_0.0001.dr_0.1.l_2.a_tanh.o_rmsprop.rep_0.best_val_loss.h5'))


targets.qc = []

if config.args.sequencing == 'paired':
    for sample in samples.names:
        if config.params.subsample == '--subsample':
            targets.qc.append(expand(os.path.join(dir.prinseq, "{sample}_{r12}.subsampled.fastq.gz"), sample=sample, r12=["R1", "R2", "RS"]))
        else:
            targets.qc.append(expand(os.path.join(dir.prinseq, "{sample}_{r12}.fastq.gz"), sample=sample, r12=["R1", "R2", "RS"]))
elif config.args.sequencing == 'longread':
    for sample in samples.names:
        if config.params.subsample == '--subsample':
            targets.qc.append(expand(os.path.join(dir.nanopore, "{sample}_S.subsampled.fastq.gz"), sample=sample))
        else:
            targets.qc.append(expand(os.path.join(dir.nanopore, "{sample}_S.fastq.gz"), sample=sample))


targets.assemble = []

if config.args.sequencing == 'paired':
    targets.assemble.append(expand(os.path.join(dir.megahit, "{sample}-pr", "final.contigs.fa"),sample=samples.names))
    targets.assemble.append(expand(os.path.join(dir.megahit, "{sample}-pr", "final.gfa"),sample=samples.names))
    targets.assemble.append(expand(os.path.join(dir.megahit, "{sample}-pr", "results", "sample_coverage.tsv"),sample=samples.names))
    targets.assemble.append(expand(os.path.join(dir.megahit, "{sample}-pr", "final.contigs_result_table.csv"),sample=samples.names))
    targets.assemble.append(expand(os.path.join(dir.megahit, "{sample}-pr", "graph_seq_details_megahit.tsv"),sample=samples.names))
    targets.assemble.append(expand(os.path.join(dir.megahit, "{sample}-pr", "checkv", "quality_summary.tsv"), sample=samples.names))
    targets.assemble.append(expand(os.path.join(dir.assembly, "{sample}-assembly-stats_megahit.csv"),sample=samples.names))
    targets.assemble.append(expand(os.path.join(dir.genome, "{sample}-pr", "{sample}.fasta"), sample=samples.names))
elif config.args.sequencing == 'longread':
    targets.assemble.append(expand(os.path.join(dir.flye, "{sample}-sr", "assembly.fasta"),sample=samples.names, file=[".fasta", "_graph.gfa", "_info.txt"]))
    targets.assemble.append(expand(os.path.join(dir.flye, "{sample}-sr", "consensus.fasta"),sample=samples.names))
    targets.assemble.append(expand(os.path.join(dir.flye, "{sample}-sr", "results", "sample_coverage.tsv"),sample=samples.names))
    targets.assemble.append(expand(os.path.join(dir.flye,"{sample}-sr","{file}"),sample=samples.names, file=["assembly_result_table.csv","graph_seq_details_flye.tsv"]))
    targets.assemble.append(expand(os.path.join(dir.flye, "{sample}-sr", "checkv", "quality_summary.tsv"), sample=samples.names))
    targets.assemble.append(expand(os.path.join(dir.assembly,"{sample}-assembly-stats_flye.csv"),sample=samples.names))
    targets.assemble.append(expand(os.path.join(dir.genome, "{sample}-sr", "{sample}.fasta"), sample=samples.names))


targets.annotate = []
if config.args.sequencing == 'paired':
    targets.annotate.append(expand(os.path.join(dir.pharokka, "{sample}-pr", "pharokka.gbk"), sample=samples.names))
    targets.annotate.append(expand(os.path.join(dir.pharokka, "{sample}-pr", "pharokka_plot.png"), sample=samples.names))
    targets.annotate.append(expand(os.path.join(dir.pharokka, "{sample}-pr", "phynteny", "phynteny.gbk"), sample=samples.names))
elif config.args.sequencing == 'longread':
    targets.annotate.append(expand(os.path.join(dir.pharokka, "{sample}-sr", "pharokka.gbk"), sample=samples.names))
    targets.annotate.append(expand(os.path.join(dir.pharokka, "{sample}-sr", "pharokka_plot.png"), sample=samples.names))
    targets.annotate.append(expand(os.path.join(dir.pharokka, "{sample}-sr", "phynteny", "phynteny.gbk"), sample=samples.names))


targets.coverage = []
if config.args.sequencing == 'paired':
    cov_dir = dir.genome
    targets.coverage.append(expand(os.path.join(cov_dir, "{sample}-pr", "temp", "{sample}.bam"), sample=samples.names))
    targets.coverage.append(expand(os.path.join(cov_dir, "{sample}-pr", "temp", "{sample}.bam.bai"), sample=samples.names))
    targets.coverage.append(expand(os.path.join(cov_dir, "{sample}-pr", "temp", "{sample}.cov"), sample=samples.names))
    targets.coverage.append(expand(os.path.join(cov_dir, "{sample}-pr", "temp", "megahit_{sample}.gencov.tsv"), sample=samples.names))
elif config.args.sequencing == 'longread':
    cov_dir = dir.genome
    targets.coverage.append(expand(os.path.join(cov_dir, "{sample}-sr", "temp", "{sample}.bam"), sample=samples.names))
    targets.coverage.append(expand(os.path.join(cov_dir, "{sample}-sr", "temp", "{sample}.bam.bai"), sample=samples.names))
    targets.coverage.append(expand(os.path.join(cov_dir, "{sample}-sr", "temp", "{sample}.cov"), sample=samples.names))
    targets.coverage.append(expand(os.path.join(cov_dir, "{sample}-sr", "temp", "flye_{sample}.gencov.tsv"), sample=samples.names))

targets.prebuild = []
targets.prebuild.append(os.path.join(dir.out, "koverage.prebuild"))
targets.prebuild.append(os.path.join(dir.out, "trimnami.prebuild"))
