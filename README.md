# glimmerhmm
Source-built GlimmerHMM container with static binaries.

## how to use
```bash
docker run --rm -v "$(pwd):/data" picotainers/glimmerhmm:latest --help
```

## prediction example
```bash
docker run --rm -v "$(pwd):/data" picotainers/glimmerhmm:latest \
  /data/genome.fa /opt/glimmerhmm/trained_dir/human -g -o /data/predictions.gff
```
