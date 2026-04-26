# glimmerhmm

Source-built container for `glimmerhmm`, a gene prediction tool for eukaryotic genomes.

## Quick Usage

```bash
docker pull docker.io/picotainers/glimmerhmm:latest
docker run --rm docker.io/picotainers/glimmerhmm:latest --help
```

## Usage

```bash
# run gene prediction with mounted input/output files
docker run --rm -v "$(pwd):/data" docker.io/picotainers/glimmerhmm:latest \
  /data/genome.fa /opt/glimmerhmm/trained_dir/human -g -o /data/predictions.gff
```

## Building

```bash
docker build -t docker.io/picotainers/glimmerhmm:latest .
```
