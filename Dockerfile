# syntax=docker/dockerfile:1

FROM debian:bookworm-slim AS builder

ARG GLIMMERHMM_VERSION=3.0.4
ARG GLIMMERHMM_URL=https://ccb.jhu.edu/software/glimmerhmm/dl/GlimmerHMM-3.0.4.tar.gz
ARG GLIMMERHMM_SHA256=43e321792b9f49a3d78154cbe8ddd1fb747774dccb9e5c62fbcc37c6d0650727

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl g++ make \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
RUN curl -fsSL "$GLIMMERHMM_URL" -o glimmerhmm.tar.gz \
    && echo "$GLIMMERHMM_SHA256  glimmerhmm.tar.gz" | sha256sum -c - \
    && tar -xzf glimmerhmm.tar.gz

WORKDIR /src/GlimmerHMM/sources
# Upstream makefile allows CFLAGS override; static link works for this tool.
RUN make -f makefile CFLAGS="-O2 -static" \
    && test -x glimmerhmm \
    && cp glimmerhmm /tmp/glimmerhmm-static

WORKDIR /tmp
RUN cat > glimmerhmm-wrapper.c <<'WRAP'
#include <string.h>
#include <unistd.h>

int main(int argc, char **argv) {
  const char *bin = "/usr/local/bin/glimmerhmm-bin";
  if (argc > 1 && strcmp(argv[1], "--help") == 0) {
    argv[1] = "-h";
  }
  argv[0] = (char *)bin;
  execv(bin, argv);
  return 127;
}
WRAP
RUN gcc -O2 -static -s -o /tmp/glimmerhmm /tmp/glimmerhmm-wrapper.c

FROM scratch

COPY --from=builder /tmp/glimmerhmm /usr/local/bin/glimmerhmm
COPY --from=builder /tmp/glimmerhmm-static /usr/local/bin/glimmerhmm-bin
COPY --from=builder /src/GlimmerHMM/trained_dir /opt/glimmerhmm/trained_dir
COPY --from=builder /src/GlimmerHMM/trained_dir /opt/conda/share/glimmerhmm/trained_dir

WORKDIR /data
ENTRYPOINT ["/usr/local/bin/glimmerhmm"]
