# Extract lists of chromosomes and segment lines valid for the data
import glob


def main():
    file_prefix = "1KG_phase3_subset_chr"
    file_suffix = ".vcf.gz"
    segments_file = "segments.txt"

    available_gds_files = set(glob.glob("*.gds"))
    # print(available_gds_files)

    chromosomes_present = set()
    segments = []
    with open(segments_file, "r") as f:
        for n, line in enumerate(f.readlines()):
            chrom = line.split()[0]
            if file_prefix + chrom + file_suffix + ".gds" in available_gds_files:
                chromosomes_present.add(chrom)
                segments += [n]
                # R uses 1 indexing, but line 0 is the header, so it all works out

    with open("chromosomes_present.txt", "w") as f:
        f.write(",".join([str(c) for c in chromosomes_present]))

    with open("segments_present.txt", "w") as f:
        f.write(",".join([str(s) for s in segments]))


if __name__ == "__main__":
    main()
