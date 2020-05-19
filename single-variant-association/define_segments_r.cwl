#!/usr/bin/env cwl-runner

# Though this tool uses the config file, it only retrieves one field from it:
# the `out_file` field. We fill that in here with a fixed value.

class: CommandLineTool
cwlVersion: v1.0
doc: |
  Wraps the UW-GAC TopMED tool `define_segments.R`

requirements:
  DockerRequirement:
    dockerPull: uwgac/topmed-master:2.6.0
  ResourceRequirement:
    coresMin: 1
    ramMin: 2000
  InitialWorkDirRequirement:
    listing:
    - entryname: define_segments.config
      entry: |
        genome_build: $(inputs.genome_build)
        out_file segments.txt

inputs:
  genome_build:
    type:
      type: enum
      symbols:
      - hg38
      - hg19
    default: hg38
  n_segments:
    doc: Number of segments (overrides segment length)
    type: int?
    inputBinding:
      prefix: --n_segments
  segment_length:
    doc: Segment length in kb
    type: int?
    default: 10000
    inputBinding:
      prefix: --segment_length

outputs:
  segments:
    type: File
    outputBinding:
      glob: segments.txt

baseCommand:
- Rscript
- /usr/local/analysis_pipeline/R/define_segments.R
- define_segments.config
arguments: []
