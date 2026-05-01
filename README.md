# glimmerhmm
Source-built GlimmerHMM container with static binaries.

## Quick Usage

```bash
# Pull the image
docker pull docker.io/picotainers/glimmerhmm:latest

# Run the tool
docker run --rm docker.io/picotainers/glimmerhmm:latest glimmerhmm --help
```

## Prediction Example

```bash
docker run --rm -v "$(pwd):/data" docker.io/picotainers/glimmerhmm:latest \
  /data/genome.fa /opt/glimmerhmm/trained_dir/human -g -o /data/predictions.gff
```
