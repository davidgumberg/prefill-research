# SSH key setup
You will probably have to modify this value for your setup, this is just an example!

```bash
export DEPLOY_SSH_KEY=$(cat ~/.ssh/id_ed25519_sk.pub)
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
    -e DEPLOY_SSH_KEY="$DEPLOY_SSH_KEY" \
    nix
```

## Inside the Container

### Nix configuration management

First, to generate a file that exposes our environment variables in nix, since
`--impure` can't be used with nixos-anywhere I think:

```bash
./abuse-nix.sh
```

## Deploy the nodes!!

First the prefill-sending node...

```bash
nix run github:nix-community/nixos-anywhere -- \
    --flake .#prefill-sender-node \
    root@$SENDER_IP
```

Next the prefill-receiving node...

```bash
nix run github:nix-community/nixos-anywhere -- \
    --flake .#prefill-receiver-node \
    root@$RECEIVER_IP
```


# Nix redeployment

If you have to...🕰️

```bash
nix run nixpkgs#nixos-rebuild -- \
  switch \
  --flake .#prefill-sender-node \
  --target-host root@$SENDER_IP
```
