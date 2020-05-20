class: CommandLineTool
cwlVersion: v1.0
label: vcf2gds
doc: |
  Convert VCF to GDS. 
  Output file name is <input filename>.gds

requirements:
- class: ResourceRequirement
  coresMin: $(inputs.cpu)
  ramMin: $(inputs.memory_gb * 1024)
- class: DockerRequirement
  dockerPull: uwgac/topmed-master:2.6.0
- class: InitialWorkDirRequirement
  listing:
  - entryname: script.sh
    writable: false
    entry: |-
      set -x
      export NSLOTS=$(inputs.cpu)
      Rscript /usr/local/analysis_pipeline/R/vcf2gds.R vcf2gds.config
      cp vcf2gds.config vcf2gds.config.log

  - entryname: vcf2gds.config
    writable: false
    entry: |-
      vcf_file "$(inputs.vcf_file.path)"
      format "${return inputs.format.join(' ')}"
      gds_file "$(inputs.vcf_file.basename).gds"
- class: InlineJavascriptRequirement

inputs:
- id: vcf_file
  label: Variants File
  type: File
  sbg:fileTypes: VCF, VCF.GZ, BCF, BCF.GZ
- id: memory_gb
  label: memory GB
  doc: Memory in GB
  type: float?
  default: 4
- id: cpu
  label: cpu
  doc: Number of CPUs for each tool job.
  type: int?
  default: 1
- id: format
  label: Format
  doc: 'Format fields to keep in GDS file. Default: GT'
  type: string[]?
  default: [GT]

outputs:
- id: gds_output
  label: GDS Output File
  doc: GDS Output File.
  type: File?
  outputBinding:
    glob: '*.gds'
  sbg:fileTypes: GDS

baseCommand: [sh, script.sh]
arguments: []
$namespaces:
  sbg: https://sevenbridges.com
