#!/usr/bin/env bash
# One command to prove airlock works across every harness.
# Prereq: a tool-calling llama-server on the host :11434 (see README.md).
set -euo pipefail
cd "$(dirname "$0")"
echo "==> Building + starting one container per harness (first run installs each framework)…"
docker compose up -d --build
echo "==> Running the verification grid…"
docker compose run --rm harness-tests
rc=$?
echo "==> Tearing down…"
docker compose down
exit $rc
