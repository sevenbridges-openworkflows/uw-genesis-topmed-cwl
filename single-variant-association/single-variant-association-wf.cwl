#!/usr/bin/env cwl-runner

class: Workflow
cwlVersion: v1.0
doc: |
  UW GAC (GENESIS) Singe Variant Association Workflow
$namespaces:
  sbg: https://sevenbridges.com

requirements:
  ScatterFeatureRequirement: {}
  StepInputExpressionRequirement: {}
  InlineJavascriptRequirement: {}

inputs:
  gds_files:
    label: GDS file
    doc: List of GDS files produced by VCF2GDS tool.
    type: File[]
    sbg:fileTypes: GDS
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
  null_model_file:
    type: File
    sbg:fileTypes: Rdata
  out_prefix:
    type: string?
    default: sva_
  phenotype_file:
    type: File
    sbg:fileTypes: Rdata
  segment_length:
    doc: Segment length in kb
    type: int?
    default: 10000

outputs:
  plots:
    type: File[]
    outputSource: plot/plots
  data:
    type: File[]
    outputSource: combine_shards/combined
  x1:
    type: string[]
    outputSource: filter_segments/chromosomes
  x2:
    type: string[]
    outputSource: filter_segments/segments
  x3:
    type: File
    outputSource: define_segments/segment_file

steps:
- id: define_segments
  in:
    genome_build: 
      source: genome_build
    n_segments: 
      source: n_segments
    segment_length: 
      source: segment_length
  run: define_segments_r.cwl
  out:
  - segment_file
- id: split_filename
  in:
    vcf_file:
      valueFrom: $(self[0])
      source: gds_files
  run: ../vcftogds/splitfilename.cwl
  out:
  - file_prefix
  - file_suffix
- id: filter_segments
  in:
    file_prefix: 
      source: split_filename/file_prefix
    file_suffix:  
      source: split_filename/file_suffix
    gds_files:  
      source: gds_files
    segment_file:  
      source: define_segments/segment_file
  run: filter_segments.cwl
  out:
  - chromosomes
  - segments
- id: single_association
  in:
    file_prefix:  
      source: split_filename/file_prefix
    file_suffix:  
      source: split_filename/file_suffix
    gds_files:  
      source: gds_files
    genome_build:  
      source: genome_build
    null_model_file:  
      source: null_model_file
    out_prefix:  
      source: out_prefix
    phenotype_file:  
      source: phenotype_file
    segment:  
      source: filter_segments/segments
    segment_file:  
      source: define_segments/segment_file
  scatter: segment
  run: assoc_single_r.cwl
  out:
  - assoc_single
- id: combine_shards
  in:
    chromosome:  
      source: filter_segments/chromosomes
    file_shards:  
      source: single_association/assoc_single
      valueFrom: ${
        var file = [];
        for(var i = 0 ; i < self.length; i++) {
          if(self[i]) {
            file.push(self[i])
          }
        }
        return file
        }

    out_prefix:  
      source: out_prefix
  scatter: chromosome
  run: assoc_combine_r.cwl
  out:
  - combined
- id: plot
  in:
    chromosomes:  
      source: filter_segments/chromosomes
    combined:  
      source: combine_shards/combined
    out_prefix:  
      source: out_prefix
  run: assoc_plots_r.cwl
  out:
  - plots
