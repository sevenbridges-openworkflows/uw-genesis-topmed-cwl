#!/usr/bin/env cwl-runner

class: Workflow
cwlVersion: v1.0
label: UW GAC (GENESIS) VCF to GDS
doc: |-
  **VCF to GDS** workflow converts VCF or BCF files into Genomic Data Structure
  (GDS) format. GDS files are required by all workflows utilizing the GENESIS or
  SNPRelate R packages. 

  _Filename requirements_:
  The input file names should follow the pattern <A>chr<X>.<y>
  For example: 1KG_phase3_subset_chr1.vcf.gz
  Some of the tools inside the workflow infer the chromosome number from the
  file by expecting this pattern of file name.
$namespaces:
  sbg: https://sevenbridges.com

requirements:
- class: ScatterFeatureRequirement
- class: StepInputExpressionRequirement

inputs:
- id: vcf_files
  label: Variants Files
  doc: Input Variants Files.
  type: File[]
  sbg:fileTypes: VCF, VCF.GZ, BCF, BCF.GZ
- id: memory_gb
  label: memory GB
  doc: |-
    Memory to allocate per job. For low number of samples (up to 10k), default 1GB is usually enough. For larger number of samples, value should be set higher (50k samples ~ 4GB). Default: 1
  type: float?
- id: format
  label: Format
  doc: 'Format fields to keep in GDS file. Default: GT'
  type: string[]?
- id: cpu
  label: Number of CPUs
  doc: Number of CPUs for each tool job.
  type: int?

outputs:
- id: unique_variant_id_gds_per_chr
  label: Unique variant ID corrected GDS files per chromosome
  doc: Corrected GDS files per chromosome.
  type: File[]?
  outputSource: unique_variant_id/gds
  sbg:fileTypes: GDS
- id: check_logs
  type: File[]
  outputSource: check_gds/check_log

steps:
- id: vcf2gds
  label: vcf2gds
  in:
  - id: vcf_file
    source: vcf_files
  - id: memory_gb
    source: memory_gb
  - id: cpu
    source: cpu
  - id: format
    source:
    - format
  scatter:
  - vcf_file
  run: vcf2gds.cwl
  out:
  - id: gds_output
- id: sniff_filename
  in:
  - id: vcf_file
    valueFrom: $(self[0])
    source: vcf_files
  run: splitfilename.cwl
  out:
  - id: file_prefix
  - id: file_suffix
- id: unique_variant_id
  label: Unique Variant ID
  in:
  - id: gds_file
    source: vcf2gds/gds_output
  - id: file_prefix
    source: sniff_filename/file_prefix
  - id: file_suffix
    source: sniff_filename/file_suffix
  run: unique_variant_id.cwl
  out:
  - id: gds
- id: check_gds
  label: Check GDS
  in:
  - id: vcf_file
    source: vcf_files
  - id: gds_file
    source: unique_variant_id/gds
  - id: file_prefix
    source: sniff_filename/file_prefix
  - id: file_suffix
    source: sniff_filename/file_suffix
  scatter:
  - gds_file
  run: check_gds.cwl
  out:
  - id: check_log

hints:
- class: sbg:AWSInstanceType
  value: c5.18xlarge;ebs-gp2;700
- class: sbg:maxNumberOfParallelInstances
  value: '8'
