#!/usr/bin/env bash

set -e

# Validate environment variables
: "${DEPLOY_SSH_KEY:?DEPLOY_SSH_KEY is not set}"
: "${SENDER_IP:?SENDER_IP is not set}"
: "${RECEIVER_IP:?RECEIVER_IP is not set}"

cat > env.nix <<EOF
{
    deploySSHKey = "$DEPLOY_SSH_KEY";
    senderIP = "$SENDER_IP";
    receiverIP = "$RECEIVER_IP";
}
EOF

# Trick nix by pretending that we intend to add 🐫
git add --intent-to-add env.nix
