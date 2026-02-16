# syntax=docker/dockerfile:1
# Compatibility-first template for glimmerhmm.
# Keep tool execution inside the conda env via micromamba run to avoid missing interpreter/lib issues.

FROM mambaorg/micromamba:2.0.5-debian12-slim

RUN micromamba install -y -n base -c conda-forge -c bioconda \
    glimmerhmm \
    setuptools \
    && micromamba clean --all --yes

# Resolve a runnable command for this package.
# Prefer exact match, then underscore variant, then prefix match.
RUN set -eux; \
    BIN=""; \
    if [ -x "/opt/conda/bin/glimmerhmm" ]; then BIN="/opt/conda/bin/glimmerhmm"; fi; \
    if [ -z "$BIN" ]; then CAND="/opt/conda/bin/$(echo glimmerhmm | tr '-' '_')"; [ -x "$CAND" ] && BIN="$CAND" || true; fi; \
    if [ -z "$BIN" ]; then BIN="$(find /opt/conda/bin -maxdepth 1 -type f -perm -111 -name 'glimmerhmm*' | head -n1 || true)"; fi; \
    test -n "$BIN"; \
    printf '%s\n' "$BIN" > /tmp/tool-entry-path

USER root
RUN set -eux; \
    BIN="$(cat /tmp/tool-entry-path)"; \
    { \
      echo '#!/usr/bin/env bash'; \
      echo 'set -euo pipefail'; \
      echo "BIN=\"$BIN\""; \
      echo 'run_candidate() {'; \
      echo '  local candidate="${1:-}"'; \
      echo '  local tmp'; \
      echo '  tmp="$(mktemp)"'; \
      echo '  set +e'; \
      echo '  if [ -n "$candidate" ]; then'; \
      echo '    micromamba run -n base "$BIN" "$candidate" >"$tmp" 2>&1'; \
      echo '  else'; \
      echo '    micromamba run -n base "$BIN" >"$tmp" 2>&1'; \
      echo '  fi'; \
      echo '  local ec=$?'; \
      echo '  set -e'; \
      echo '  if [ "$ec" -eq 0 ]; then'; \
      echo '    cat "$tmp"'; \
      echo '    rm -f "$tmp"'; \
      echo '    return 0'; \
      echo '  fi'; \
      echo '  if grep -Eiq "(usage|help|options|version|available|commands?)" "$tmp"; then'; \
      echo '    cat "$tmp"'; \
      echo '    rm -f "$tmp"'; \
      echo '    return 0'; \
      echo '  fi'; \
      echo '  cat "$tmp" >&2'; \
      echo '  rm -f "$tmp"'; \
      echo '  return "$ec"'; \
      echo '}'; \
      echo 'if [ "${1:-}" = "--help" ]; then'; \
      echo '  shift'; \
      echo '  run_candidate "--help" || run_candidate "-h" || run_candidate "help" || run_candidate ""'; \
      echo '  exit $?'; \
      echo 'fi'; \
      echo 'exec micromamba run -n base "$BIN" "$@"'; \
    } > /usr/local/bin/glimmerhmm
RUN chmod +x /usr/local/bin/glimmerhmm && rm -f /tmp/tool-entry-path
WORKDIR /data
ENTRYPOINT ["/usr/local/bin/glimmerhmm"]
