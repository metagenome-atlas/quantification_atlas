
import os

configfile: os.path.join(os.path.dirname(workflow.snakefile),"config/default_config.yaml")


SAMPLES=config['samples'].keys()

include: "rules/bbsketch.smk"

rule all:
    input:
        expand("Results_{ref}_{NTorAA}.json",
                  ref=config['references'].keys(),
                  NTorAA='aa' if config['translate'] else 'nt')
