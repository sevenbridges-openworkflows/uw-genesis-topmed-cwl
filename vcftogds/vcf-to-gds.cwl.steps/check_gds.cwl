class: CommandLineTool
cwlVersion: v1.0
label: check_gds

requirements:
- class: ResourceRequirement
  ramMin: 1000
- class: DockerRequirement
  dockerPull: uwgac/topmed-master:2.6.0
- class: InitialWorkDirRequirement
  listing:

  - entryname: script.sh
    writable: false
    entry: |-
      set -e
      SCRIPT=/usr/local/analysis_pipeline/R/check_gds.R
      CHROM=${return inputs.gds_file.path.split('chr')[1].split('.')[0];}
      Rscript $SCRIPT check_gds.config --chromosome $CHROM || true

  - entryname: check_gds.config
    writable: false
    entry: |-
      vcf_file "$(inputs.file_prefix) $(inputs.file_suffix)"
      gds_file "$(inputs.file_prefix) $(inputs.file_suffix).gds"
  - $(inputs.vcf_file)
  - $(inputs.gds_file)
         
- class: InlineJavascriptRequirement

inputs:
- id: vcf_file
  label: Variants file
  doc: VCF or BCF files can have two parts split by chromosome identifier.
  type: File[]
  sbg:category: Inputs
  sbg:fileTypes: VCF, VCF.GZ, BCF, BCF.GZ
- id: gds_file
  label: GDS File
  doc: GDS file produced by conversion.
  type: File
  sbg:fileTypes: gds
- id: file_prefix
  type: string
  doc: "pre in <pre><chrom#><suf>.gds"
- id: file_suffix
  type: string
  doc: "suf in <pre><chrom#><suf>.gds"

outputs:
- id: check_log
  type: File
  outputBinding:
    glob: "*.check.log"

baseCommand: [sh, script.sh]
arguments: []

$namespaces:
  sbg: https://sevenbridges.com

stderr: $(inputs.gds_file.basename).check.log
