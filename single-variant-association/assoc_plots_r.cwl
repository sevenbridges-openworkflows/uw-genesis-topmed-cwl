#!/usr/bin/env cwl-runner

class: CommandLineTool
cwlVersion: v1.0
doc: |
  Wraps the UW-GAC TopMED tool `assoc_plots.R`
$namespaces:
  sbg: https://sevenbridges.com

requirements:
  DockerRequirement:
    dockerPull: uwgac/topmed-master:2.6.0
  ResourceRequirement:
    coresMin: 1
    ramMin: 2000
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing:
    - $(inputs.combined)
    - entryname: plots.config
      entry: |
        assoc_type "single"
        assoc_file "$(inputs.out_prefix)_chr .RData"
        chromosomes "$(inputs.chromosomes.join(" "))"
        out_file_manh "$(inputs.out_prefix)_manhattan.png"
        out_file_qq "$(inputs.out_prefix)_qq.png"

inputs:
  out_prefix:
    type: string
  chromosomes:
    type: string[]
  combined:
    type: File[]
    doc: List of files from assoc_combine_r.cwl

outputs:
  plots:
    type: File[]
    outputBinding:
      glob: "*.png"

baseCommand:
- Rscript
- /usr/local/analysis_pipeline/R/assoc_plots.R
- plots.config
arguments: []
