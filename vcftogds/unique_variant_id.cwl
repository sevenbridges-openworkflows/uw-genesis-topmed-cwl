class: CommandLineTool
cwlVersion: v1.0
label: unique_variant_id
doc: |
  Ensures that each variant has a unique integer ID across the genome, so the
  variant.id field in per-chromosome files and combined files are consistent. 
  
  Expects 

  From: https://github.com/UW-GAC/analysis_pipeline

requirements:
- class: DockerRequirement
  dockerPull: uwgac/topmed-master:2.6.0
- class: InitialWorkDirRequirement
  listing:
    - entryname: script.sh
      writable: false
      entry: |
        set -x
        Rscript /usr/local/analysis_pipeline/R/unique_variant_ids.R unique_variant_ids.config || true

    - entryname: unique_variant_ids.config
      writable: false
      entry: |
        gds_file "$(inputs.file_prefix) $(inputs.file_suffix).gds"

    - $(inputs.gds_file)

- class: InlineJavascriptRequirement

inputs:
- id: gds_file
  label: GDS file
  doc: List of GDS files produced by VCF2GDS tool.
  type: File[]
- id: file_prefix
  type: string
  doc: "pre in <pre><chrom#><suf>.gds"
- id: file_suffix
  type: string
  doc: "suf in <pre><chrom#><suf>.gds"
outputs:
- id: gds
  label: Unique variant ID corrected GDS files per chromosome
  type: File[]?
  outputBinding:
    glob: '*.gds'
  sbg:fileTypes: GDS

baseCommand: [sh, script.sh]
arguments: []
$namespaces:
  sbg: https://sevenbridges.com

