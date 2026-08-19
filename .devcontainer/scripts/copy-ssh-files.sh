#!/usr/bin/env bash
set -Eeuo pipefail
# Prerequisite: The .ssh files must be mounted to ~/.sshtemplate before running this script.
#  "source=${localEnv:HOME}/.ssh,target=/home/container-user/.sshtemplate,type=bind,readonly,consistency=cached"
#
# Copy only the top-level *regular files* from the template into ~/.ssh
# (keys, known_hosts, config, ...) - whatever they're named. We deliberately
# do NOT recurse into subfolders and do NOT copy anything that isn't a plain
# file: the host ~/.ssh can contain live, host-only artifacts (e.g. SSH-agent
# forwarding sockets, often under an "agent" subfolder) that can't/shouldn't
# end up in the container. Filtering by type this way needs no naming
# convention and can't accidentally pick up a socket, wherever it lives.

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

copied=0
while IFS= read -r -d '' entry; do
  name="$(basename "${entry}")"
  if cp -pf "${entry}" "${SSH_DIR}/${name}" 2>/dev/null; then
    copied=$((copied + 1))
  else
    echo "WARN: skipping ${entry} (unreadable or vanished)" >&2
  fi
done < <(find "${TEMPLATE_DIR}" -maxdepth 1 -mindepth 1 -type f -print0)

if [ "${copied}" -eq 0 ]; then
  echo "No regular files found directly in ${TEMPLATE_DIR}; nothing copied."
fi

if [ -f "${SSH_DIR}/config" ]; then
  chmod 600 "${SSH_DIR}/config" 2>/dev/null || true
fi

chmod 700 "${SSH_DIR}"
find "${SSH_DIR}" -mindepth 1 -type d -exec chmod 700 {} + 2>/dev/null || true
find "${SSH_DIR}" -mindepth 1 -type f -exec chmod 600 {} + 2>/dev/null || true
echo "Copied ${copied} SSH file(s) from .sshtemplate."
