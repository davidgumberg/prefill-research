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

We are going to deploy the nodes out of order to avoid
https://github.com/bitcoin/bitcoin/issues/34096, note that after this set-up,
the receiving node will not be connected to the sending node, so we'll have to
restart it in a bit...

First the prefill-receiving node...

```bash
nix run github:nix-community/nixos-anywhere -- \
    --flake .#prefill-receiver-node \
    root@$RECEIVER_IP
```

Next the prefill-sending node...

```bash
nix run github:nix-community/nixos-anywhere -- \
    --flake .#prefill-sender-node \
    root@$SENDER_IP
```

After a little while....

```bash
ssh root@$RECEIVER_IP
cat /bitcoin/debug.log
```

If you see output that looks like the node has gotten past pre-synchronizing
blockheaders, e.g.:

```
2025-12-18T04:09:44.926975Z [bench]     - Index writing: 0.03ms [0.14s (0.01ms/blk)]
2025-12-18T04:09:44.926988Z [bench]   - Connect total: 0.20ms [5.36s (0.56ms/blk)]
2025-12-18T04:09:44.927006Z [bench]   - Flush: 0.02ms [0.66s (0.07ms/blk)]
2025-12-18T04:09:44.927015Z [bench]   - Writing chainstate: 0.01ms [0.13s (0.01ms/blk)]
2025-12-18T04:09:44.927032Z UpdateTip: new best=00000000000006ca2953083c6e8c349d03311745eed4451fa44e5e5404261ff6 height=156861 version=0x00000001 log2_work=67.317518 tx=2003489 date='2011-12-10T02:34:21Z' progress=0.001558 cache=43.8MiB(334830txo)
2025-12-18T04:09:44.927040Z [bench]   - Connect postprocess: 0.02ms [0.30s (0.03ms/blk)]
2025-12-18T04:09:44.927048Z [bench] - Connect block: 0.28ms [7.27s (0.76ms/blk)]
2025-12-18T04:09:44.927102Z [bench]   - Load block from disk: 0.03ms
```

Then go ahead and restart the node on the receiver so that the receiver node
connects to the sending node:

```bash
systemctl restart bitcoind
```

We can ensure that we've connected to the receiving node and marked it as high
bandwidth after the restart by looking for a message with a recent timestamp,
e.g.:

```bash
grep -P "Adding peer \d+ as a high bandwidth" /bitcoin/debug.log
```

# Nix redeployment

If you have to...🕰️

sender:
```bash
nix run nixpkgs#nixos-rebuild -- \
  switch \
  --flake .#prefill-sender-node \
  --target-host root@$SENDER_IP
```

receiver
```bash
nix run nixpkgs#nixos-rebuild -- \
  switch \
  --flake .#prefill-receiver-node \
  --target-host root@$RECEIVER_IP
```

