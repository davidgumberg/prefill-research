# Hetzner deployment
hcloud server create --name prefill-sender --type cpx32 --location hel1 --image fedora-42 --ssh-key fido

# Nix deployment
docker run -it --rm \
    -v "./:/workspace" \
    -v $SSH_AUTH_SOCK:/ssh-agent -e SSH_AUTH_SOCK=/ssh-agent \
    -e SENDER_IP="$(hcloud server ip prefill-sender)" \
    nix

nix run github:nix-community/nixos-anywhere -- \
    --flake .#prefill-sender-node \
    root@$SENDER_IP


# Nix redeployment

nix run nixpkgs#nixos-rebuild -- \
  switch \
  --flake .#prefill-sender-node \
  --target-host root@$SENDER_IP
