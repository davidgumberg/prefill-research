#!/usr/bin/env bash

cat > env.nix <<EOF
{
    deploySSHKey = "$DEPLOY_SSH_KEY";
    senderIP = "$SENDER_IP";
    receiverIP = "$RECEIVER_IP";
}
EOF

# Trick nix by pretending that we intend to add 🐫
git add --intent-to-add env.nix
