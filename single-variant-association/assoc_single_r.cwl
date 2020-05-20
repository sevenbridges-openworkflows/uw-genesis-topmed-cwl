#!/usr/bin/env cwl-runner

# We stage all the GDS files and select based on the chomosome and segment
# inputs.
# The segment refers to the line number (starting at 1) of the segment_file
# (segment 1 turns out to be the header line)
# The segment file contains the chromosome number. However, the script can not
# infer this from the line.
# However, it checks the passed chromosome number against the chromosome number
# in the segment file to make sure they are consistent.

class: CommandLineTool
cwlVersion: v1.0
doc: |
  Wraps the UW-GAC TopMED tool `assoc_single.R`
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
    - $(inputs.gds_files)
    - entryname: assoc_single.config
      entry: |
        out_prefix $(inputs.out_prefix)
        genome_build $(inputs.genome_build)
        gds_file "$(inputs.file_prefix) $(inputs.file_suffix)"
        null_model_file "$(inputs.null_model_file.path)"
        phenotype_file "$(inputs.phenotype_file.path)"
        segment_file "$(inputs.segment_file.path)"
    - entryname: script.sh
      entry: |
        set -x
        # This is a bit of cleverness we have to do to extract the chromosome
        # number from the segments file and pass it to the R script
        CHROM="\$(awk 'NR==$(inputs.segment) {print $1}' $(inputs.segment_file.path))"
        Rscript /usr/local/analysis_pipeline/R/assoc_single.R assoc_single.config --chromosome $CHROM --segment $(inputs.segment)

inputs:
  file_prefix:
    type: string
  file_suffix:
    type: string
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
  null_model_file:
    type: File
    sbg:fileTypes: Rdata
  out_prefix:
    type: string?
    default: sva_
  phenotype_file:
    type: File
    sbg:fileTypes: Rdata
  segment:
    type: int
  segment_file:
    type: File
    sbg:fileTypes: TXT

outputs:
  assoc_single:
    type: File?
    outputBinding:
      glob: $(inputs.out_prefix)*

baseCommand:
- sh
- script.sh
arguments: []
