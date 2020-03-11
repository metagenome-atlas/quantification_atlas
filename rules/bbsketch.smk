





rule sketch_ref:
    input:
        lambda wildcards: config['references'][wildcards.ref]
    output:
        out="bbsketch/{ref}_{NTorAA}.sketch.gz"
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

def get_qc_reads(wildcards):

    return config['samples'][wildcards.sample]

rule sketch_sample:
    input:
        input=get_qc_reads
    output:
        out="bbsketch/{sample}_{NTorAA}.sketch.gz"
    params:
        k= lambda wildcards: config['k'][wildcards.NTorAA],
        translate=lambda wildcards: wildcards.NTorAA=='aa',
        overwrite=True,
        command=f"bbsketch.sh depth depth2",
        processSSU=False,
        name=lambda wildcards: wildcards.sample
    resources:
        time= 10
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
        expand("bbsketch/{sample}_{{NTorAA}}.sketch.gz",sample=SAMPLES),
        ref="bbsketch/{ref}_{NTorAA}.sketch.gz",
    output:
        out="Results_{ref}_{NTorAA}.json"
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
