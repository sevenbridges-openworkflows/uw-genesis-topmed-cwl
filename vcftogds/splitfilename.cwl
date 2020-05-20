class: CommandLineTool
cwlVersion: v1.0
label: Split Filename

requirements:
- class: ResourceRequirement
  ramMin: 4000
- class: DockerRequirement
  dockerPull: uwgac/topmed-master:2.6.0
- class: InlineJavascriptRequirement

inputs:
- id: vcf_file
  label: Variants file
  doc: Input file to sniff for file name splitting
  type: File
  sbg:fileTypes: VCF, VCF.GZ, BCF, BCF.GZ

outputs:
- id: file_prefix
  type: string
  outputBinding:
    outputEval: ${return inputs.vcf_file.basename.split('chr')[0]}chr
- id: file_suffix
  type: string
  outputBinding:
    outputEval: |
      ${
        var suffix = inputs.vcf_file.path.split('chr')[1].split(".");
        suffix.shift(); // Get right of the chrom number
        return "." + suffix.join(".");
      }

baseCommand: [echo]
$namespaces:
  sbg: https://sevenbridges.com