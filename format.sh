#!/usr/bin/env bash

cat network-healthcheck.sh | \
  sed --regexp-extended 's/\$/\\\\$\$/g' | \
  sed --regexp-extended 's/^\s+//' | \
  sed --regexp-extended ':a;N;$!ba;s/\n+/\n/g;s/\n/ /g' | \
  (read OUT && \
   (echo -n sh -c \"$OUT\" > docker-compose.sh))
