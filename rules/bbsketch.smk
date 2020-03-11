





rule sketch_ref:
    input:
        lambda wildcards: config['references'][wildcards.ref]
    output:
        out="bbsketch/reference/{ref}_{NTorAA}.sketch.gz"
    params:
        k= lambda wildcards: config['k'][wildcards.NTorAA],
        translate=lambda wildcards: wildcards.NTorAA=='aa',
        overwrite=True,
        command=lambda wildcards, input: f"bbsketch.sh perfile depth depth2 {input}/*.f*",
    resources:
        time= 10
    log:
        "logs/bbsketch/sketch_{ref}_{NTorAA}.log"
    benchmark:
        "logs/benchmark/bbsketch/sketch_{ref}_{NTorAA}.txt"
    conda:
        "../envs/bbmap.yaml"
    threads:
        config['threads']
    script:
        "../scripts/runBB.py"

rule merge_pairs:
    input:
        lambda wildcards: get_quality_controlled_reads_(wildcards,sampleTable,['R1','R2'])
    output:
        outmerged="{sample}/reads/merged_me.fastq.gz",
        outu="{sample}/reads/merged_R1.fastq.gz",
        outu2="{sample}/reads/merged_R2.fastq.gz"
    threads:
        config["threads"]
    params:
        command="bbmerge.sh"
    resources:
        time= 10
    log:
        "logs/bbsketch/merge/{sample}.log"
    benchmark:
        "logs/benchmark/bbsketch/merge_{sample}.txt"
    conda:
        "../envs/bbmap.yaml"
    threads:
        config['threads']
    script:
        "../scripts/runBB.py"



rule sketch_paired_sample:
    input:
        rules.merge_pairs.output,
        lambda wc: get_quality_controlled_reads_(wc,sampleTable,['se'])
    output:
        out="bbsketch/samples/{sample}_{NTorAA}.sketch.gz"
    params:
        input= lambda wc, input: ','.join(input),
        k= lambda wildcards: config['k'][wildcards.NTorAA],
        translate=lambda wildcards: wildcards.NTorAA=='aa',
        overwrite=True,
        command=f"bbsketch.sh depth depth2",
        processSSU=False,
        minprob=0.2, # for ilumina reads
        minkeycount=2,
        name=lambda wildcards: wildcards.sample
    log:
        "logs/bbsketch/sketch_{sample}_{NTorAA}.log"
    benchmark:
        "logs/benchmark/bbsketch/sketch_{sample}_{NTorAA}.txt"
    conda:
        "../envs/bbmap.yaml"
    threads:
        config['threads']
    script:
        "../scripts/runBB.py"


rule compare:
    input:
        expand("bbsketch/samples/{sample}_{{NTorAA}}.sketch.gz",sample=SAMPLES),
        ref="bbsketch/reference/{ref}_{NTorAA}.sketch.gz",
    output:
        out="Results_{ref}_{NTorAA}.json.gz"
    params:
        input=lambda wildcards: ','.join(expand("bbsketch/{sample}_{NTorAA}.sketch.gz",sample=SAMPLES,**wildcards)),
        k= lambda wildcards: config['k'][wildcards.NTorAA],
        overwrite=True,
        command=f"comparesketch.sh ",
        format='json',
        ssu=False,
        printdepth=True,
        printdepth2=True,
        printtaxid=False,
        printtaxname=False,
        printnohit=True,
        printvolume=True, #Product of average depth and matches
    log:
        "logs/bbsketch/compare_{ref}_{NTorAA}.log"
    benchmark:
        "logs/benchmark/bbsketch/compare_{ref}_{NTorAA}.txt"
    conda:
        "../envs/bbmap.yaml"
    threads:
        config['threads']
    script:
        "../scripts/runBB.py"
