#!/usr/bin/env bash
set -Eeuo pipefail
# Prerequisite: The .ssh files must be mounted to ~/.sshtemplate before running this script.
#  "source=${localEnv:HOME}/.ssh,target=/home/container-user/.sshtemplate,type=bind,readonly,consistency=cached"
# Copy all SSH files from template to ~/.ssh and set permissions

TEMPLATE_DIR="${HOME}/.sshtemplate"
SSH_DIR="${HOME}/.ssh"

if command -v tree >/dev/null 2>&1; then
  tree "${TEMPLATE_DIR}" || true
else
  ls -la "${TEMPLATE_DIR}" || true
fi

if [ ! -d "${TEMPLATE_DIR}" ] || [ -z "$(ls -A "${TEMPLATE_DIR}" 2>/dev/null)" ]; then
  echo "No SSH template mounted at ${TEMPLATE_DIR}; skipping SSH setup."
  exit 0
fi

mkdir -p "${SSH_DIR}" || {
  echo "ERROR: creating SSH dir failed" >&2
  exit 1
}
cp -rf "${TEMPLATE_DIR}/." "${SSH_DIR}/" || {
  echo "ERROR: copying SSH template failed" >&2
  exit 1
}

if [ -f "${TEMPLATE_DIR}/config" ]; then
  chmod 600 "${SSH_DIR}/config" 2>/dev/null || true
fi

chmod 700 "${SSH_DIR}"
find "${SSH_DIR}" -mindepth 1 -type d -exec chmod 700 {} + 2>/dev/null || true
find "${SSH_DIR}" -mindepth 1 -type f -exec chmod 600 {} + 2>/dev/null || true
echo "SSH files copied from .sshtemplate."
