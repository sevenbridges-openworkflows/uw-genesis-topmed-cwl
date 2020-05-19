#!/usr/bin/env cwl-runner

# This wraps the define_segments_r.cwl 
# The one bit of cleverness in this script is the use of loadContents and a
# JS expression to create a list of integers representing the lines in the
# segments.txt file. We can scatter over this list to drive assoc_single_r.cwl
# It is possible to fail this expression if the segments file gets too big. 
# However, at that stage you are probably scattering over too many segments

class: CommandLineTool
cwlVersion: v1.0
doc: |
  Wraps the UW-GAC TopMED tool `define_segments.R`. Also produces a list of
  integers representing the lines in the segments.txt file that can be used to
  scatter assoc_single_r.cwl
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
    - entryname: define_segments.config
      entry: |
        genome_build $(inputs.genome_build)
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
  segments_file:
    type: File
    outputBinding:
      glob: segments.txt

baseCommand:
- Rscript
- /usr/local/analysis_pipeline/R/define_segments.R
- define_segments.config
arguments: []
