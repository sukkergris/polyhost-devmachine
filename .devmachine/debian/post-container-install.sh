#!/usr/bin/env bash
set -eu

export NVM_DIR="$HOME/.nvm"
# shellcheck disable=SC1091
[ -s "${NVM_DIR}/nvm.sh" ] && . "${NVM_DIR}/nvm.sh"

dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# The devcontainer runs as root, so mounted config volumes should stay root-owned.
# Keep the directories present and accessible without a chown dance.
mkdir -p \
  /root/.claude \
  /root/.claude-json \
  /root/.copilot \
  /root/.continue \
  /root/.ssh \
  /root/.sshtemplate \
  2>/dev/null || true
chmod 700 /root/.ssh /root/.sshtemplate 2>/dev/null || true

SCRIPTS_DIR="${dir}/../scripts"

COPY_SSH_SCRIPT="$SCRIPTS_DIR/copy-ssh-files.sh"
if [[ ! -f "$COPY_SSH_SCRIPT" ]]; then
  echo "ERROR: Script not found: $COPY_SSH_SCRIPT" >&2
  exit 1
fi

bash "$COPY_SSH_SCRIPT"

SCRIPT="$SCRIPTS_DIR/remove-userkeychain.sh"
if [[ ! -f "$SCRIPT" ]]; then
  echo "ERROR: Script not found: $SCRIPT" >&2
  exit 1
fi

bash "$SCRIPT" ~/.ssh/config

GLOBAL_NPM_SCRIPT="$SCRIPTS_DIR/install-global-npm-tools.sh"
if [[ ! -f "$GLOBAL_NPM_SCRIPT" ]]; then
  echo "ERROR: Script not found: $GLOBAL_NPM_SCRIPT" >&2
  exit 1
fi

bash "$GLOBAL_NPM_SCRIPT"

claude --print "." > /dev/null 2>&1 || true

echo "Post container install script done running"
