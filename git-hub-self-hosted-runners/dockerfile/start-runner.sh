#!/usr/bin/env bash
set -euo pipefail

: "${RUNNER_REGISTRATION_TOKEN:?Set the GitHub organisation registration token}"

cd /home/runner

./config.sh \
  --unattended \
  --url "https://github.com/tapan-patel-org" \
  --token "$RUNNER_REGISTRATION_TOKEN" \
  --name "aca-$(hostname)-$(date +%s)" \
  --labels "azure-container-apps" \
  --ephemeral \
  --disableupdate

unset RUNNER_REGISTRATION_TOKEN
exec ./run.sh