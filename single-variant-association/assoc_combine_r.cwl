#!/usr/bin/env cwl-runner

# The tool only needs the prefix and the chromosome number because it infers the
# segment name from it's own internal file naming scheme.
# The output file name is also generated deterministically according to
# https://github.com/UW-GAC/analysis_pipeline/blob/2e55b32756939bd301cdddfef1f55b1957ee6c71/TopmedPipeline/R/utils.R#L110

# The tool is dangerous in that it does not raise any errors if it does not
# find the required files

class: CommandLineTool
cwlVersion: v1.0
doc: |
  Wraps the UW-GAC TopMED tool `assoc_combine.R` for single association only
$namespaces:
  sbg: https://sevenbridges.com

requirements:
  DockerRequirement:
    dockerPull: uwgac/topmed-master:2.6.0
  ResourceRequirement:
    coresMin: 1
    ramMin: 2000
  InitialWorkDirRequirement:
    listing:
    - $(inputs.file_shards)
    - entryname: assoc_combine.config
      entry: |
        out_prefix $(inputs.out_prefix)
        assoc_type "single"

inputs:
  chromosome:
    type: string
    inputBinding:
      prefix: --chromosome
  file_shards:
    doc: List of files produced by assoc_single_r tool.
    type: File[]
    sbg:fileTypes: Rdata
  out_prefix:
    type: string

outputs:
  combined:
    type: File?
    outputBinding:
      glob: $(inputs.out_prefix)_chr$(inputs.chromosome).RData

baseCommand:
- Rscript
- /usr/local/analysis_pipeline/R/assoc_combine.R
- assoc_combine.config
