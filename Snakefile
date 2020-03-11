
import os,sys

configfile: os.path.join(os.path.dirname(workflow.snakefile),"config/default_config.yaml")

sys.path.append(os.path.join(os.path.dirname(workflow.snakefile),"scripts"))

import pandas as pd
from sample_table import *

sampleTable= load_sample_table(config.get('sample_table','samples.tsv'))
SAMPLES = sampleTable.index.values


include: "rules/bbsketch.smk"

rule all:
    input:
        expand("Results_{ref}_{NTorAA}.json.gz",
                  ref=config['references'].keys(),
                  NTorAA='aa' if config['translate'] else 'nt')
