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
  chromosomes:
    type: int[]
    outputBinding:
      outputEval: |-
        ${
          // A simple script to generate a list of chromosomes to scatter over
          var out = []
          for(var i = 1; i < 25; i++) {
            out.push(i)
          }
          return out
        }
  segments:
    type: int[]
    outputBinding:
      glob: segments.txt
      outputEval: |-
        ${
          // A bit of cleverness to load the segments.txt file and print a list
          // of integers from 1 ... number of lines. This can be used to scatter
          // the assoc_single_r.cwl
          // It is possible to fail this expression if the segments file gets too
          // big. However, at that stage you are probably scattering over too many
          // segments
          var out = []
          for(var i = 1; i < self[0].contents.split(/\r\n|\r|\n/).length; i++) {
            out.push(i)
          }
          return out
        }
      loadContents: true
  segments_file:
    type: File
    outputBinding:
      glob: segments.txt

baseCommand:
- Rscript
- /usr/local/analysis_pipeline/R/define_segments.R
- define_segments.config
arguments: []
