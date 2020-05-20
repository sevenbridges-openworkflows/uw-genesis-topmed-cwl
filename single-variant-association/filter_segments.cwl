#!/usr/bin/env cwl-runner

# Python script to determine which segment lines are valid for our given data
# set. The resulting list of segments can be used to scatter assoc_single_r.cwl
# and the chromosomes can be used to scatter assoc_gather_r.cwl

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
    dockerPull: python:3.7-alpine
  ResourceRequirement:
    coresMin: 1
    ramMin: 2000
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing:
    - $(inputs.gds_files)
    - entryname: filter-segments.py
      entry: |
        # Extract lists of chromosomes and segment lines valid for the data
        import glob


        def main():
            file_prefix = "$(inputs.file_prefix)"
            file_suffix = "$(inputs.file_suffix)"
            segments_file = "$(inputs.segment_file.path)"

            available_gds_files = set(glob.glob("*.gds"))

            chromosomes_present = set()
            segments = []
            with open(segments_file, "r") as f:
                for n, line in enumerate(f.readlines()):
                    chrom = line.split()[0]
                    if file_prefix + chrom + file_suffix in available_gds_files:
                        chromosomes_present.add(chrom)
                        segments += [n + 1] 
                        # R uses 1 indexing, but line 0 is the header, so it all works out

            with open("chromosomes_present.txt", "w") as f:
                f.write(",".join([str(c) for c in chromosomes_present]))

            with open("segments_present.txt", "w") as f:
                f.write(",".join([str(s) for s in segments]))


        if __name__ == "__main__":
            main()

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
  segment_file:
    doc: segments.txt file produced by define_segments_r.cwl
    type: File

outputs:
  chromosomes:
    type: string[]
    outputBinding:
      glob: chromosomes_present.txt
      outputEval: $(self[0].contents.split(","))
      loadContents: true
  segments:
    type: string[]
    outputBinding:
      glob: segments_present.txt
      outputEval: $(self[0].contents.split(","))
      loadContents: true


baseCommand:
- python3
- filter-segments.py
arguments: []
