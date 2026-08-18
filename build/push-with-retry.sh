#!/usr/bin/env bash
# Pushes the devmachine image, retrying with backoff on transient failures.
# Usage: build/push-with-retry.sh
set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

max_attempts=4
attempt=1
while true; do
  echo "Push attempt ${attempt}/${max_attempts}..."
  if docker compose --env-file .env -f docker-compose.yml push debian-mac; then
    echo "Push succeeded."
    break
  fi
  if [ "$attempt" -ge "$max_attempts" ]; then
    echo "Push failed after ${max_attempts} attempts."
    exit 1
  fi
  sleep_seconds=$((attempt * 10))
  echo "Push failed; retrying in ${sleep_seconds}s..."
  sleep "$sleep_seconds"
  attempt=$((attempt + 1))
done
