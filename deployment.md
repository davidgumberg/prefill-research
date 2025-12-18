# Variable setup
You will probably have to modify this for your setup, this is just an example!
```bash
echo "\"$(cat ~/.ssh/id_ed25519_sk.pub)\"" > sshkey.nix
```

# Hetzner deployment

Obviously these instructions only work exactly if you're using hetzner, all that
matters is that you've got `$SENDER_IP` and `$RECEIVER_IP` set.

```bash
hcloud server create --name prefill-sender --type cpx32 --location hel1 --image fedora-42 --ssh-key $HETZNER_SSH_KEY_NAME
hcloud server create --name prefill-receiver --type cpx32 --location sin --image fedora-42 --ssh-key $HETZNER_SSH_KEY_NAME
```

```bash
export RECEIVER_IP="$(hcloud server ip prefill-receiver)"
export SENDER_IP="$(hcloud server ip prefill-sender)"
```

# Nix deployment

## Build and run the nix container
```bash
docker build -t nix .

docker run -it --rm \
    -v "./:/workspace" \
    -v $SSH_AUTH_SOCK:/ssh-agent -e SSH_AUTH_SOCK=/ssh-agent \
    -e SENDER_IP="$SENDER_IP" \
    -e RECEIVER_IP="$RECEIVER_IP" \
    nix
```

## Deploy the nodes!!
```
nix run github:nix-community/nixos-anywhere -- \
    --flake .#prefill-sender-node \
    root@$SENDER_IP
```


# Nix redeployment

```bash
nix run nixpkgs#nixos-rebuild -- \
  switch \
  --flake .#prefill-sender-node \
  --target-host root@$SENDER_IP
```
