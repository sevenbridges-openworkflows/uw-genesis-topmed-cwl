#!/usr/bin/env cwl-runner

class: CommandLineTool
cwlVersion: v1.0
label: UW GENESIS null_model.R
$namespaces:
  sbg: https://sevenbridges.com

requirements:
  DockerRequirement:
    dockerPull: uwgac/topmed-master:2.6.0
  ResourceRequirement:
    coresMin: 2
  InitialWorkDirRequirement:
    listing:
    - entryname: null_model.config
      entry: |
        # From https://github.com/UW-GAC/analysis_pipeline#null-model
        out_prefix $(inputs.out_prefix)
        phenotype_file $(inputs.phenotype_file.path)
        outcome $(inputs.outcome)
        binary $(inputs.outcome_is_binary)
        ${
          if(inputs.pca_file) 
            return "pca_file " + inputs.pca_file.path
          else return ""
        }
        ${
          if(inputs.relatedness_matrix) 
            return "relatedness_matrix " + inputs.relatedness_matrix.path
          else return ""
        }
        ${
          if(inputs.covariates) 
            return "covars " + inputs.covariates
          else return ""
        }
    - entryname: script.sh
      entry: |
        set -x
        cat null_model.config
        Rscript /usr/local/analysis_pipeline/R/null_model.R null_model.config

        NULLDIR=$(inputs.out_prefix)_datadir
        mkdir $NULLDIR
        mv $(inputs.out_prefix)*.RData $NULLDIR/
  InlineJavascriptRequirement: {}

inputs:
  covariates:
    doc: |-
      Names of columns phenotype_file containing covariates, quoted and separated by spaces.
    type: string?
  out_prefix:
    doc: Prefix for files created by the software
    type: string?
    default: genesis-topmed
  outcome:
    doc: Name of column in Phenotype File containing outcome variable.
    type: string
  outcome_is_binary:
    doc: |-
      TRUE if outcome is a binary (case/control) variable; FALSE if outcome is a continuous variable.
    type:
      type: enum
      symbols:
      - 'TRUE'
      - 'FALSE'
    default: 'FALSE'
  pca_file:
    doc: RData file with PCA results created by PC-AiR.
    type: File?
    sbg:fileTypes: RDATA, Rdata
  phenotype_file:
    doc: RData file with AnnotatedDataFrame of phenotypes.
    type: File
    sbg:fileTypes: RDATA, Rdata
  relatedness_matrix:
    doc: RData or GDS file with a kinship matrix or GRM.
    type: File?
    sbg:fileTypes: GDS, RDATA, RData

outputs:
  null_model:
    doc: Null model files
    type: Directory
    outputBinding:
      glob: $(inputs.out_prefix)_datadir
  null_model_phenotype:
    doc: Phenotypes file
    type: File
    outputBinding:
      glob: '*phenotypes.RData'

baseCommand:
- sh
- script.sh
arguments: []
